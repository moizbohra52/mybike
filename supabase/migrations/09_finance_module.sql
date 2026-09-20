-- ============================================================================
-- MYBIKE Dealership Management System
-- Migration 09: Finance Module
-- Cash & Bank, Financial Vouchers (Payment, Receipt, Contra, Credit/Debit Notes),
-- Outstandings and General Ledger Integration
-- ============================================================================

-- 1. Finance Vouchers Table
CREATE TABLE IF NOT EXISTS public.finance_vouchers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    showroom_id UUID NOT NULL REFERENCES public.showrooms(id) ON DELETE RESTRICT,
    voucher_number VARCHAR(50) NOT NULL UNIQUE, -- e.g. "PMT-MUM-2026-00001", "RCT-MUM-2026-00001", "CNT-MUM-2026-00001"
    voucher_type VARCHAR(30) NOT NULL CHECK (voucher_type IN ('payment', 'receipt', 'contra', 'expense', 'credit_note', 'debit_note')),
    voucher_date DATE NOT NULL DEFAULT CURRENT_DATE,
    
    -- Party Details
    party_type VARCHAR(30) NOT NULL CHECK (party_type IN ('customer', 'supplier', 'oem', 'staff', 'bank', 'other')),
    party_id VARCHAR(100),
    party_name VARCHAR(255) NOT NULL,
    party_phone VARCHAR(20),
    
    -- Payment & Financial Account Details
    payment_mode VARCHAR(30) NOT NULL DEFAULT 'bank_transfer' CHECK (payment_mode IN ('cash', 'bank_transfer', 'upi', 'cheque', 'dd', 'clearing')),
    source_account_id UUID REFERENCES public.chart_of_accounts(id) ON DELETE RESTRICT,
    destination_account_id UUID REFERENCES public.chart_of_accounts(id) ON DELETE RESTRICT,
    
    -- Amounts
    amount NUMERIC(14, 2) NOT NULL CHECK (amount > 0),
    tax_deducted_tds NUMERIC(14, 2) NOT NULL DEFAULT 0.00 CHECK (tax_deducted_tds >= 0),
    net_amount NUMERIC(14, 2) NOT NULL CHECK (net_amount > 0),
    
    -- Instrumentation & Reference
    reference_number VARCHAR(100), -- Cheque no, UTR, UPI Ref, Original Invoice No
    reference_date DATE,
    bank_name VARCHAR(100),
    narration TEXT NOT NULL,
    
    -- Lifecycle & General Ledger Linkage
    status VARCHAR(20) NOT NULL DEFAULT 'posted' CHECK (status IN ('draft', 'posted', 'cancelled')),
    journal_entry_id UUID REFERENCES public.journal_entries(id) ON DELETE SET NULL,
    created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updatedAt TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_finance_vouchers_showroom ON public.finance_vouchers(showroom_id);
CREATE INDEX IF NOT EXISTS idx_finance_vouchers_type ON public.finance_vouchers(voucher_type);
CREATE INDEX IF NOT EXISTS idx_finance_vouchers_date ON public.finance_vouchers(voucher_date DESC);
CREATE INDEX IF NOT EXISTS idx_finance_vouchers_party ON public.finance_vouchers(party_id);
CREATE INDEX IF NOT EXISTS idx_finance_vouchers_status ON public.finance_vouchers(status);

-- 2. Finance Voucher Number Generator Function
CREATE OR REPLACE FUNCTION public.generate_finance_voucher_number(
    p_showroom_id UUID,
    p_voucher_type VARCHAR,
    p_date DATE DEFAULT CURRENT_DATE
)
RETURNS VARCHAR AS $$
DECLARE
    v_showroom_code VARCHAR(10);
    v_type_prefix VARCHAR(5);
    v_year_str VARCHAR(4);
    v_next_val INT;
    v_result VARCHAR(50);
BEGIN
    SELECT COALESCE(code, 'HO') INTO v_showroom_code
    FROM public.showrooms WHERE id = p_showroom_id;

    v_year_str := TO_CHAR(p_date, 'YYYY');

    CASE p_voucher_type
        WHEN 'payment' THEN v_type_prefix := 'PMT';
        WHEN 'receipt' THEN v_type_prefix := 'RCT';
        WHEN 'contra' THEN v_type_prefix := 'CNT';
        WHEN 'expense' THEN v_type_prefix := 'EXP';
        WHEN 'credit_note' THEN v_type_prefix := 'CRN';
        WHEN 'debit_note' THEN v_type_prefix := 'DBN';
        ELSE v_type_prefix := 'FIN';
    END CASE;

    SELECT COUNT(*) + 1 INTO v_next_val
    FROM public.finance_vouchers
    WHERE showroom_id = p_showroom_id
      AND voucher_type = p_voucher_type
      AND EXTRACT(YEAR FROM voucher_date) = EXTRACT(YEAR FROM p_date);

    v_result := v_type_prefix || '-' || v_showroom_code || '-' || v_year_str || '-' || LPAD(v_next_val::TEXT, 5, '0');
    RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Row Level Security (RLS)
ALTER TABLE public.finance_vouchers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "finance_vouchers_select_policy"
ON public.finance_vouchers
FOR SELECT
TO authenticated
USING (
    showroom_id IN (
        SELECT showroom_id FROM public.user_showrooms WHERE user_id = auth.uid() AND is_active = true
    )
    OR EXISTS (
        SELECT 1 FROM public.user_roles ur
        JOIN public.roles r ON ur.role_id = r.id
        WHERE ur.user_id = auth.uid() AND r.name IN ('Super Admin', 'Director', 'General Manager')
    )
);

CREATE POLICY "finance_vouchers_insert_policy"
ON public.finance_vouchers
FOR INSERT
TO authenticated
WITH CHECK (
    showroom_id IN (
        SELECT showroom_id FROM public.user_showrooms WHERE user_id = auth.uid() AND is_active = true
    )
    OR EXISTS (
        SELECT 1 FROM public.user_roles ur
        JOIN public.roles r ON ur.role_id = r.id
        WHERE ur.user_id = auth.uid() AND r.name IN ('Super Admin', 'Accountant', 'Showroom Manager')
    )
);

CREATE POLICY "finance_vouchers_update_policy"
ON public.finance_vouchers
FOR UPDATE
TO authenticated
USING (
    showroom_id IN (
        SELECT showroom_id FROM public.user_showrooms WHERE user_id = auth.uid() AND is_active = true
    )
);
