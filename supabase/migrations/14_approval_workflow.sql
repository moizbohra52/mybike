-- ============================================================================
-- MYBIKE ERP — Phase 21: Multi-Transaction Approval Workflow System
-- Migration: 14_approval_workflow.sql
-- ============================================================================

-- 1. Approval Rules Table (Configurable Threshold Policies)
CREATE TABLE IF NOT EXISTS public.approval_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transaction_type VARCHAR(50) NOT NULL, -- 'expense', 'discount', 'purchase', 'payment', 'stock_adjustment', 'stock_transfer', 'other'
    name VARCHAR(150) NOT NULL,
    description TEXT,
    threshold_amount DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    required_role VARCHAR(50) NOT NULL, -- 'showroom_manager', 'sales_manager', 'accountant', 'admin', 'cfo'
    showroom_id UUID REFERENCES public.showrooms(id) ON DELETE CASCADE, -- NULL = applies to all showrooms
    is_active BOOLEAN NOT NULL DEFAULT true,
    auto_approve_below_threshold BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. Approval Requests Table (Transaction Instances)
CREATE TABLE IF NOT EXISTS public.approval_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rule_id UUID REFERENCES public.approval_rules(id) ON DELETE SET NULL,
    transaction_type VARCHAR(50) NOT NULL, -- 'expense', 'discount', 'purchase', 'payment', 'stock_adjustment', 'stock_transfer', 'other'
    record_id VARCHAR(100) NOT NULL, -- e.g. Voucher ID, Invoice ID, PO ID, Transfer ID
    record_reference VARCHAR(100), -- Human readable ref e.g. EXP-2026-00088, INV-2026-00042
    title VARCHAR(255) NOT NULL,
    description TEXT,
    amount DECIMAL(15, 2), -- NULL for non-monetary requests like stock adjustments
    requester_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    requester_name VARCHAR(150),
    requester_role VARCHAR(50),
    showroom_id UUID REFERENCES public.showrooms(id) ON DELETE SET NULL,
    showroom_name VARCHAR(150),
    status VARCHAR(30) NOT NULL DEFAULT 'pending', -- 'pending', 'approved', 'rejected', 'cancelled'
    urgency VARCHAR(20) NOT NULL DEFAULT 'normal', -- 'low', 'normal', 'high', 'critical'
    approver_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    approver_name VARCHAR(150),
    approved_at TIMESTAMPTZ,
    rejection_reason TEXT,
    approval_notes TEXT,
    payload JSONB, -- Contextual data snapshot of the transaction
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3. Performance Indexes
CREATE INDEX IF NOT EXISTS idx_approval_requests_status ON public.approval_requests(status, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_approval_requests_type ON public.approval_requests(transaction_type, status);
CREATE INDEX IF NOT EXISTS idx_approval_requests_showroom ON public.approval_requests(showroom_id, status);
CREATE INDEX IF NOT EXISTS idx_approval_requests_requester ON public.approval_requests(requester_id);
CREATE INDEX IF NOT EXISTS idx_approval_rules_type ON public.approval_rules(transaction_type, is_active);

-- 4. Triggers for updated_at
CREATE TRIGGER trigger_approval_rules_updated_at
    BEFORE UPDATE ON public.approval_rules
    FOR EACH ROW EXECUTE FUNCTION handle_updated_at();

CREATE TRIGGER trigger_approval_requests_updated_at
    BEFORE UPDATE ON public.approval_requests
    FOR EACH ROW EXECUTE FUNCTION handle_updated_at();

-- 5. Row Level Security (RLS)
ALTER TABLE public.approval_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.approval_requests ENABLE ROW LEVEL SECURITY;

CREATE POLICY "approval_rules_select_policy"
ON public.approval_rules FOR SELECT
USING (true);

CREATE POLICY "approval_rules_modify_policy"
ON public.approval_rules FOR ALL
USING (public.is_admin() OR public.has_permission(auth.uid(), 'settings', 'edit'));

CREATE POLICY "approval_requests_select_policy"
ON public.approval_requests FOR SELECT
USING (
    public.is_admin() OR
    public.has_permission(auth.uid(), 'approvals', 'view') OR
    requester_id = auth.uid() OR
    showroom_id IS NULL OR
    showroom_id IN (
        SELECT showroom_id FROM public.user_showrooms WHERE user_id = auth.uid()
    )
);

CREATE POLICY "approval_requests_insert_policy"
ON public.approval_requests FOR INSERT
WITH CHECK (true);

CREATE POLICY "approval_requests_update_policy"
ON public.approval_requests FOR UPDATE
USING (
    public.is_admin() OR
    public.has_permission(auth.uid(), 'approvals', 'edit')
);
