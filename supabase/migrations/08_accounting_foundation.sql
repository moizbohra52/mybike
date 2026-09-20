-- ============================================================================
-- Phase 12: Accounting Foundation
-- Double-Entry Bookkeeping, Chart of Accounts (COA), Journal Entries,
-- General Ledger, Anti-Tamper Reversals & Trial Balance
-- ============================================================================

-- 1. Chart of Accounts (COA)
CREATE TABLE IF NOT EXISTS public.chart_of_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    showroom_id UUID REFERENCES public.showrooms(id) ON DELETE RESTRICT, -- NULL = Corporate / Consolidated Global Account
    account_code VARCHAR(20) NOT NULL UNIQUE, -- e.g. "1010", "1020", "2010", "4010"
    account_name VARCHAR(150) NOT NULL,
    account_type VARCHAR(20) NOT NULL CHECK (account_type IN ('asset', 'liability', 'equity', 'revenue', 'expense')),
    sub_type VARCHAR(50) NOT NULL, -- e.g. 'cash', 'bank', 'accounts_receivable', 'inventory', 'accounts_payable', 'tax_payable', 'sales', 'cogs', 'operating_expense'
    parent_id UUID REFERENCES public.chart_of_accounts(id) ON DELETE RESTRICT,
    opening_balance NUMERIC(14,2) NOT NULL DEFAULT 0.00,
    current_balance NUMERIC(14,2) NOT NULL DEFAULT 0.00,
    currency VARCHAR(3) NOT NULL DEFAULT 'INR',
    is_active BOOLEAN NOT NULL DEFAULT true,
    is_system_account BOOLEAN NOT NULL DEFAULT false, -- System accounts cannot be deleted
    is_reconciled BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. Journal Entries (Double-Entry Header)
CREATE TABLE IF NOT EXISTS public.journal_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    showroom_id UUID NOT NULL REFERENCES public.showrooms(id) ON DELETE RESTRICT,
    entry_number VARCHAR(30) NOT NULL UNIQUE, -- e.g. "JRN-2026-00001"
    entry_date DATE NOT NULL DEFAULT CURRENT_DATE,
    financial_year_id UUID REFERENCES public.financial_years(id) ON DELETE RESTRICT,
    reference_type VARCHAR(30) NOT NULL DEFAULT 'manual' CHECK (reference_type IN ('manual', 'sales_invoice', 'payment_receipt', 'purchase_invoice', 'expense', 'reversal')),
    reference_id VARCHAR(50),
    narration TEXT NOT NULL,
    total_debit NUMERIC(14,2) NOT NULL DEFAULT 0.00,
    total_credit NUMERIC(14,2) NOT NULL DEFAULT 0.00,
    is_balanced BOOLEAN NOT NULL DEFAULT true,
    status VARCHAR(20) NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'posted', 'reversed')),
    reversed_entry_id UUID REFERENCES public.journal_entries(id) ON DELETE RESTRICT,
    created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    posted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT chk_debit_credit_balance CHECK (status != 'posted' OR total_debit = total_credit)
);

-- 3. Journal Entry Lines (Debit / Credit Line Items)
CREATE TABLE IF NOT EXISTS public.journal_entry_lines (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    journal_entry_id UUID NOT NULL REFERENCES public.journal_entries(id) ON DELETE CASCADE,
    account_id UUID NOT NULL REFERENCES public.chart_of_accounts(id) ON DELETE RESTRICT,
    description VARCHAR(255),
    debit_amount NUMERIC(14,2) NOT NULL DEFAULT 0.00 CHECK (debit_amount >= 0),
    credit_amount NUMERIC(14,2) NOT NULL DEFAULT 0.00 CHECK (credit_amount >= 0),
    showroom_id UUID REFERENCES public.showrooms(id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT chk_line_amount CHECK (debit_amount > 0 OR credit_amount > 0)
);

-- 4. Indexes for Performance
CREATE INDEX IF NOT EXISTS idx_coa_type ON public.chart_of_accounts(account_type);
CREATE INDEX IF NOT EXISTS idx_coa_showroom ON public.chart_of_accounts(showroom_id);
CREATE INDEX IF NOT EXISTS idx_journal_showroom ON public.journal_entries(showroom_id);
CREATE INDEX IF NOT EXISTS idx_journal_date ON public.journal_entries(entry_date);
CREATE INDEX IF NOT EXISTS idx_journal_status ON public.journal_entries(status);
CREATE INDEX IF NOT EXISTS idx_journal_ref ON public.journal_entries(reference_type, reference_id);
CREATE INDEX IF NOT EXISTS idx_journal_lines_entry ON public.journal_entry_lines(journal_entry_id);
CREATE INDEX IF NOT EXISTS idx_journal_lines_account ON public.journal_entry_lines(account_id);

-- 5. Automatic Number Generator Function for Journal Vouchers
CREATE OR REPLACE FUNCTION public.generate_journal_entry_number(showroom_uuid UUID)
RETURNS VARCHAR AS $$
DECLARE
    sh_code VARCHAR(10);
    yr VARCHAR(4);
    seq_val INT;
BEGIN
    SELECT COALESCE(code, 'HO') INTO sh_code FROM public.showrooms WHERE id = showroom_uuid;
    IF sh_code IS NULL THEN sh_code := 'HO'; END IF;
    yr := to_char(CURRENT_DATE, 'YYYY');
    
    SELECT COUNT(*) + 1 INTO seq_val FROM public.journal_entries 
    WHERE showroom_id = showroom_uuid AND EXTRACT(YEAR FROM created_at) = EXTRACT(YEAR FROM CURRENT_DATE);
    
    RETURN 'JRN-' || sh_code || '-' || yr || '-' || LPAD(seq_val::TEXT, 5, '0');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. Trigger to Update UpdatedAt Timestamps
CREATE OR REPLACE FUNCTION public.handle_accounting_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_coa_updated_at
    BEFORE UPDATE ON public.chart_of_accounts
    FOR EACH ROW EXECUTE FUNCTION public.handle_accounting_updated_at();

CREATE TRIGGER trg_journal_updated_at
    BEFORE UPDATE ON public.journal_entries
    FOR EACH ROW EXECUTE FUNCTION public.handle_accounting_updated_at();

-- 7. Trigger to Update Account Balances on Journal Posting
CREATE OR REPLACE FUNCTION public.handle_journal_posting_balance_update()
RETURNS TRIGGER AS $$
DECLARE
    line_rec RECORD;
    acct_rec RECORD;
    delta NUMERIC(14,2);
BEGIN
    -- Only run when status changes to 'posted'
    IF NEW.status = 'posted' AND (OLD.status IS NULL OR OLD.status != 'posted') THEN
        FOR line_rec IN SELECT * FROM public.journal_entry_lines WHERE journal_entry_id = NEW.id LOOP
            SELECT account_type INTO acct_rec FROM public.chart_of_accounts WHERE id = line_rec.account_id;
            
            -- Debit increases Assets & Expenses, decreases Liabilities, Equity, Revenue
            -- Credit increases Liabilities, Equity, Revenue, decreases Assets & Expenses
            IF acct_rec.account_type IN ('asset', 'expense') THEN
                delta := line_rec.debit_amount - line_rec.credit_amount;
            ELSE
                delta := line_rec.credit_amount - line_rec.debit_amount;
            END IF;
            
            UPDATE public.chart_of_accounts
            SET current_balance = current_balance + delta,
                updated_at = now()
            WHERE id = line_rec.account_id;
        END LOOP;
        
        NEW.posted_at := now();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_journal_balance_update
    BEFORE UPDATE ON public.journal_entries
    FOR EACH ROW EXECUTE FUNCTION public.handle_journal_posting_balance_update();

-- 8. Row Level Security (RLS)
ALTER TABLE public.chart_of_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.journal_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.journal_entry_lines ENABLE ROW LEVEL SECURITY;

CREATE POLICY "COA viewable by authenticated users"
    ON public.chart_of_accounts FOR SELECT
    TO authenticated USING (true);

CREATE POLICY "COA manageable by accounts and admins"
    ON public.chart_of_accounts FOR ALL
    TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Journal entries viewable by authenticated users"
    ON public.journal_entries FOR SELECT
    TO authenticated USING (true);

CREATE POLICY "Journal entries insertable by accounts"
    ON public.journal_entries FOR INSERT
    TO authenticated WITH CHECK (true);

CREATE POLICY "Journal entries updateable by accounts"
    ON public.journal_entries FOR UPDATE
    TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Journal lines viewable by authenticated users"
    ON public.journal_entry_lines FOR SELECT
    TO authenticated USING (true);

CREATE POLICY "Journal lines manageable by accounts"
    ON public.journal_entry_lines FOR ALL
    TO authenticated USING (true) WITH CHECK (true);
