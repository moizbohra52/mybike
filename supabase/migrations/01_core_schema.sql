-- ============================================================================
-- MYBIKE ERP — Phase 3: Core Database Schema Migration
-- ============================================================================
-- Description: Core schema, profiles, multi-showroom tables, RBAC,
--              financial year, invoice sequences, audit logs, and triggers.
-- ============================================================================

-- Enable essential extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- 1. Helper Functions & Triggers
-- ============================================================================

-- Generic updated_at trigger function
CREATE OR REPLACE FUNCTION handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Auto-create profile on auth.users sign up
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, full_name, is_active, created_at, updated_at)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
        true,
        now(),
        now()
    )
    ON CONFLICT (id) DO UPDATE
    SET email = EXCLUDED.email,
        updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- 2. Core Tables
-- ============================================================================

-- 2.1 Profiles (linked to auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL,
    full_name VARCHAR(150),
    phone VARCHAR(20),
    avatar_url TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Trigger for updated_at on profiles
CREATE TRIGGER trigger_profiles_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION handle_updated_at();

-- Trigger on auth.users for profile creation
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION handle_new_user();

-- 2.2 Showrooms
CREATE TABLE IF NOT EXISTS public.showrooms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    code VARCHAR(20) NOT NULL UNIQUE,
    address TEXT NOT NULL,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50) NOT NULL,
    pincode VARCHAR(10) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100),
    gstin VARCHAR(15),
    pan VARCHAR(10),
    logo_url TEXT,
    bank_name VARCHAR(100),
    bank_account_number VARCHAR(30),
    bank_ifsc VARCHAR(15),
    bank_branch VARCHAR(100),
    invoice_prefix VARCHAR(10) NOT NULL DEFAULT 'MB',
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER trigger_showrooms_updated_at
    BEFORE UPDATE ON public.showrooms
    FOR EACH ROW
    EXECUTE FUNCTION handle_updated_at();

-- 2.3 Roles
CREATE TABLE IF NOT EXISTS public.roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(50) NOT NULL UNIQUE,
    display_name VARCHAR(100) NOT NULL,
    description TEXT,
    is_system_role BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2.4 Permissions
CREATE TABLE IF NOT EXISTS public.permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    module VARCHAR(50) NOT NULL,
    action VARCHAR(20) NOT NULL, -- view, create, edit, delete, approve, export, print
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_module_action UNIQUE (module, action)
);

-- 2.5 Role Permissions Mapping
CREATE TABLE IF NOT EXISTS public.role_permissions (
    role_id UUID NOT NULL REFERENCES public.roles(id) ON DELETE CASCADE,
    permission_id UUID NOT NULL REFERENCES public.permissions(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (role_id, permission_id)
);

-- 2.6 User Roles Mapping
CREATE TABLE IF NOT EXISTS public.user_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    role_id UUID NOT NULL REFERENCES public.roles(id) ON DELETE CASCADE,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_user_role UNIQUE (user_id, role_id)
);

-- 2.7 User Showrooms (Multi-showroom access)
CREATE TABLE IF NOT EXISTS public.user_showrooms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    showroom_id UUID NOT NULL REFERENCES public.showrooms(id) ON DELETE CASCADE,
    is_default BOOLEAN NOT NULL DEFAULT false,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_user_showroom UNIQUE (user_id, showroom_id)
);

-- Helper function: Get showroom IDs assigned to a user
CREATE OR REPLACE FUNCTION get_user_showroom_ids(user_uuid UUID)
RETURNS SETOF UUID AS $$
    SELECT showroom_id FROM public.user_showrooms
    WHERE user_id = user_uuid AND is_active = true;
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- 2.8 Financial Years (Indian FY: April 1 - March 31)
CREATE TABLE IF NOT EXISTS public.financial_years (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(20) NOT NULL UNIQUE, -- e.g. "2026-27"
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_current BOOLEAN NOT NULL DEFAULT false,
    is_locked BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT chk_fy_dates CHECK (end_date > start_date)
);

CREATE TRIGGER trigger_financial_years_updated_at
    BEFORE UPDATE ON public.financial_years
    FOR EACH ROW
    EXECUTE FUNCTION handle_updated_at();

-- 2.9 Invoice Sequences
CREATE TABLE IF NOT EXISTS public.invoice_sequences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    showroom_id UUID NOT NULL REFERENCES public.showrooms(id) ON DELETE CASCADE,
    financial_year_id UUID NOT NULL REFERENCES public.financial_years(id) ON DELETE CASCADE,
    sequence_type VARCHAR(30) NOT NULL, -- sales_invoice, booking, purchase_order, quotation
    current_number INT NOT NULL DEFAULT 0,
    prefix VARCHAR(20),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_showroom_fy_sequence UNIQUE (showroom_id, financial_year_id, sequence_type)
);

CREATE TRIGGER trigger_invoice_sequences_updated_at
    BEFORE UPDATE ON public.invoice_sequences
    FOR EACH ROW
    EXECUTE FUNCTION handle_updated_at();

-- Sequence number generator function
CREATE OR REPLACE FUNCTION generate_sequence_number(
    p_showroom_id UUID,
    p_fy_id UUID,
    p_type VARCHAR
)
RETURNS VARCHAR AS $$
DECLARE
    v_prefix VARCHAR;
    v_showroom_code VARCHAR;
    v_fy_name VARCHAR;
    v_next_num INT;
    v_result VARCHAR;
BEGIN
    SELECT code INTO v_showroom_code FROM public.showrooms WHERE id = p_showroom_id;
    SELECT name INTO v_fy_name FROM public.financial_years WHERE id = p_fy_id;

    INSERT INTO public.invoice_sequences (showroom_id, financial_year_id, sequence_type, current_number)
    VALUES (p_showroom_id, p_fy_id, p_type, 1)
    ON CONFLICT (showroom_id, financial_year_id, sequence_type)
    DO UPDATE SET current_number = public.invoice_sequences.current_number + 1, updated_at = now()
    RETURNING current_number INTO v_next_num;

    -- Format: CODE/FY/TYPE/0001 (e.g. IND-MAIN/26-27/INV/0001)
    v_result := v_showroom_code || '/' || v_fy_name || '/' || UPPER(p_type) || '/' || LPAD(v_next_num::TEXT, 5, '0');
    RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2.10 Audit Logs
CREATE TABLE IF NOT EXISTS public.audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    table_name VARCHAR(50) NOT NULL,
    record_id UUID NOT NULL,
    action VARCHAR(20) NOT NULL, -- INSERT, UPDATE, DELETE
    old_data JSONB,
    new_data JSONB,
    user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    showroom_id UUID REFERENCES public.showrooms(id) ON DELETE SET NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2.11 Settings
CREATE TABLE IF NOT EXISTS public.settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    showroom_id UUID REFERENCES public.showrooms(id) ON DELETE CASCADE, -- NULL for global app settings
    key VARCHAR(100) NOT NULL,
    value JSONB NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_global_setting ON public.settings (key) WHERE showroom_id IS NULL;
CREATE UNIQUE INDEX IF NOT EXISTS uq_showroom_setting ON public.settings (showroom_id, key) WHERE showroom_id IS NOT NULL;

CREATE TRIGGER trigger_settings_updated_at
    BEFORE UPDATE ON public.settings
    FOR EACH ROW
    EXECUTE FUNCTION handle_updated_at();

-- ============================================================================
-- 3. Indexes for High Performance
-- ============================================================================
CREATE INDEX IF NOT EXISTS idx_user_showrooms_user ON public.user_showrooms(user_id);
CREATE INDEX IF NOT EXISTS idx_user_showrooms_showroom ON public.user_showrooms(showroom_id);
CREATE INDEX IF NOT EXISTS idx_user_roles_user ON public.user_roles(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_table_record ON public.audit_logs(table_name, record_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_showroom ON public.audit_logs(showroom_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_created_at ON public.audit_logs(created_at DESC);
