-- ============================================================================
-- Phase 10: Customer Management (KYC, Documents, Leads & Bookings)
-- Indian Two-Wheeler Dealership CRM: Walk-in → Lead → KYC → Booking → Delivery
-- ============================================================================

-- 1. Customers (Master Customer Record)
CREATE TABLE IF NOT EXISTS public.customers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    showroom_id UUID NOT NULL REFERENCES public.showrooms(id) ON DELETE RESTRICT,
    customer_number VARCHAR(30) NOT NULL UNIQUE, -- e.g. "CUST-IND-MAIN-0001"
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    mobile_primary VARCHAR(15) NOT NULL, -- 10-digit Indian mobile
    mobile_secondary VARCHAR(15),
    email VARCHAR(200),
    date_of_birth DATE,
    gender VARCHAR(20) CHECK (gender IN ('male', 'female', 'other', 'prefer_not_to_say')),
    -- Indian Address
    address_line_1 VARCHAR(200),
    address_line_2 VARCHAR(200),
    city VARCHAR(100),
    state VARCHAR(100),
    pin_code VARCHAR(10),
    landmark VARCHAR(200),
    -- KYC Workflow
    kyc_status VARCHAR(20) NOT NULL DEFAULT 'pending'
        CHECK (kyc_status IN ('pending', 'partial', 'verified', 'rejected')),
    kyc_verified_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    kyc_verified_at TIMESTAMPTZ,
    -- Classification
    customer_type VARCHAR(20) NOT NULL DEFAULT 'individual'
        CHECK (customer_type IN ('individual', 'corporate', 'fleet')),
    source VARCHAR(30) DEFAULT 'walk_in'
        CHECK (source IN (
            'walk_in', 'phone_call', 'website', 'social_media',
            'oem_referral', 'exchange_inquiry', 'corporate_tieup',
            'auto_expo', 'existing_customer', 'other'
        )),
    preferred_contact_method VARCHAR(20) DEFAULT 'phone'
        CHECK (preferred_contact_method IN ('phone', 'whatsapp', 'email', 'sms')),
    is_active BOOLEAN NOT NULL DEFAULT true,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER trigger_customers_updated_at
    BEFORE UPDATE ON public.customers
    FOR EACH ROW
    EXECUTE FUNCTION handle_updated_at();

-- 2. Customer Documents (KYC Identity Document Records)
CREATE TABLE IF NOT EXISTS public.customer_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL REFERENCES public.customers(id) ON DELETE CASCADE,
    document_type VARCHAR(30) NOT NULL
        CHECK (document_type IN (
            'aadhaar', 'pan', 'driving_license', 'voter_id',
            'passport', 'address_proof', 'photo', 'other'
        )),
    document_number VARCHAR(100), -- Masked/reference number
    file_name VARCHAR(200) NOT NULL,
    file_url TEXT, -- Supabase Storage URL (null in dev mode)
    file_size_bytes BIGINT DEFAULT 0,
    mime_type VARCHAR(50) DEFAULT 'application/pdf',
    verification_status VARCHAR(20) NOT NULL DEFAULT 'pending'
        CHECK (verification_status IN ('pending', 'verified', 'rejected')),
    verified_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    verified_at TIMESTAMPTZ,
    rejection_reason TEXT,
    expiry_date DATE, -- For DL, Passport
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3. Leads (Sales Lead Pipeline Tracking)
CREATE TABLE IF NOT EXISTS public.leads (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    showroom_id UUID NOT NULL REFERENCES public.showrooms(id) ON DELETE RESTRICT,
    customer_id UUID REFERENCES public.customers(id) ON DELETE SET NULL, -- May not yet be a customer
    lead_number VARCHAR(30) NOT NULL UNIQUE, -- e.g. "LEAD-IND-MAIN-0001"
    -- Prospect Info (for leads without a customer record)
    prospect_name VARCHAR(200),
    prospect_mobile VARCHAR(15),
    prospect_email VARCHAR(200),
    source VARCHAR(30) NOT NULL DEFAULT 'walk_in'
        CHECK (source IN (
            'walk_in', 'phone_call', 'website', 'social_media',
            'oem_referral', 'exchange_inquiry', 'corporate_tieup',
            'auto_expo', 'existing_customer', 'other'
        )),
    status VARCHAR(30) NOT NULL DEFAULT 'new'
        CHECK (status IN (
            'new', 'contacted', 'interested', 'test_ride_scheduled',
            'test_ride_done', 'negotiation', 'booking_initiated',
            'converted', 'lost', 'follow_up'
        )),
    interested_model_id UUID REFERENCES public.vehicle_models(id) ON DELETE SET NULL,
    interested_variant_id UUID REFERENCES public.vehicle_variants(id) ON DELETE SET NULL,
    assigned_to UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    priority VARCHAR(10) NOT NULL DEFAULT 'warm'
        CHECK (priority IN ('hot', 'warm', 'cold')),
    expected_closure_date DATE,
    last_follow_up_at TIMESTAMPTZ,
    next_follow_up_at TIMESTAMPTZ,
    lost_reason TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER trigger_leads_updated_at
    BEFORE UPDATE ON public.leads
    FOR EACH ROW
    EXECUTE FUNCTION handle_updated_at();

-- 4. Lead Activities (Interaction Timeline)
CREATE TABLE IF NOT EXISTS public.lead_activities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lead_id UUID NOT NULL REFERENCES public.leads(id) ON DELETE CASCADE,
    activity_type VARCHAR(30) NOT NULL
        CHECK (activity_type IN (
            'call', 'whatsapp', 'email', 'sms', 'walk_in',
            'test_ride', 'follow_up', 'negotiation', 'note'
        )),
    description TEXT NOT NULL,
    performed_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 5. Bookings (Vehicle Booking with Token Advance)
CREATE TABLE IF NOT EXISTS public.bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    showroom_id UUID NOT NULL REFERENCES public.showrooms(id) ON DELETE RESTRICT,
    customer_id UUID NOT NULL REFERENCES public.customers(id) ON DELETE RESTRICT,
    lead_id UUID REFERENCES public.leads(id) ON DELETE SET NULL,
    booking_number VARCHAR(30) NOT NULL UNIQUE, -- e.g. "BK-IND-MAIN-2026-0001"
    variant_id UUID NOT NULL REFERENCES public.vehicle_variants(id) ON DELETE RESTRICT,
    color_id UUID NOT NULL REFERENCES public.vehicle_colors(id) ON DELETE RESTRICT,
    allocated_vehicle_id UUID REFERENCES public.inventory_vehicles(id) ON DELETE SET NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'pending'
        CHECK (status IN (
            'pending', 'confirmed', 'allocated', 'ready_for_delivery',
            'delivered', 'cancelled', 'refunded'
        )),
    -- Payment
    booking_amount NUMERIC(12, 2) NOT NULL DEFAULT 0.0,
    payment_mode VARCHAR(20) DEFAULT 'cash'
        CHECK (payment_mode IN ('cash', 'upi', 'neft', 'cheque', 'card')),
    payment_reference VARCHAR(100),
    -- Pricing
    ex_showroom_price NUMERIC(12, 2) NOT NULL DEFAULT 0.0,
    on_road_price NUMERIC(12, 2) NOT NULL DEFAULT 0.0,
    -- Delivery
    expected_delivery_date DATE,
    actual_delivery_date DATE,
    -- Finance
    finance_required BOOLEAN NOT NULL DEFAULT false,
    finance_provider VARCHAR(100),
    loan_amount NUMERIC(12, 2) DEFAULT 0.0,
    -- Exchange
    exchange_vehicle BOOLEAN NOT NULL DEFAULT false,
    exchange_details TEXT,
    -- Cancellation
    cancelled_reason TEXT,
    cancelled_at TIMESTAMPTZ,
    -- Staff
    booked_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER trigger_bookings_updated_at
    BEFORE UPDATE ON public.bookings
    FOR EACH ROW
    EXECUTE FUNCTION handle_updated_at();

-- 6. Indexes
CREATE INDEX IF NOT EXISTS idx_customers_showroom ON public.customers(showroom_id);
CREATE INDEX IF NOT EXISTS idx_customers_mobile ON public.customers(mobile_primary);
CREATE INDEX IF NOT EXISTS idx_customers_kyc ON public.customers(kyc_status);
CREATE INDEX IF NOT EXISTS idx_customers_type ON public.customers(customer_type);
CREATE INDEX IF NOT EXISTS idx_customers_number ON public.customers(customer_number);

CREATE INDEX IF NOT EXISTS idx_customer_documents_customer ON public.customer_documents(customer_id);
CREATE INDEX IF NOT EXISTS idx_customer_documents_type ON public.customer_documents(document_type);
CREATE INDEX IF NOT EXISTS idx_customer_documents_status ON public.customer_documents(verification_status);

CREATE INDEX IF NOT EXISTS idx_leads_showroom ON public.leads(showroom_id);
CREATE INDEX IF NOT EXISTS idx_leads_customer ON public.leads(customer_id);
CREATE INDEX IF NOT EXISTS idx_leads_status ON public.leads(status);
CREATE INDEX IF NOT EXISTS idx_leads_priority ON public.leads(priority);
CREATE INDEX IF NOT EXISTS idx_leads_assigned ON public.leads(assigned_to);
CREATE INDEX IF NOT EXISTS idx_leads_number ON public.leads(lead_number);

CREATE INDEX IF NOT EXISTS idx_lead_activities_lead ON public.lead_activities(lead_id);

CREATE INDEX IF NOT EXISTS idx_bookings_showroom ON public.bookings(showroom_id);
CREATE INDEX IF NOT EXISTS idx_bookings_customer ON public.bookings(customer_id);
CREATE INDEX IF NOT EXISTS idx_bookings_status ON public.bookings(status);
CREATE INDEX IF NOT EXISTS idx_bookings_number ON public.bookings(booking_number);
CREATE INDEX IF NOT EXISTS idx_bookings_allocated ON public.bookings(allocated_vehicle_id);

-- 7. Row Level Security (RLS)
ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customer_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lead_activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;

-- Customers RLS
CREATE POLICY "Users can view customers in assigned showrooms"
    ON public.customers FOR SELECT
    TO authenticated
    USING (
        is_super_admin(auth.uid()) OR
        has_permission('customers', 'view') OR
        showroom_id IN (SELECT get_user_showroom_ids(auth.uid()))
    );

CREATE POLICY "Authorized users can manage customers"
    ON public.customers FOR ALL
    TO authenticated
    USING (
        is_super_admin(auth.uid()) OR
        has_permission('customers', 'edit') OR
        has_permission('customers', 'create')
    );

-- Customer Documents RLS
CREATE POLICY "Users can view customer documents"
    ON public.customer_documents FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Authorized users can manage customer documents"
    ON public.customer_documents FOR ALL
    TO authenticated
    USING (
        is_super_admin(auth.uid()) OR
        has_permission('customers', 'edit')
    );

-- Leads RLS
CREATE POLICY "Users can view leads in assigned showrooms"
    ON public.leads FOR SELECT
    TO authenticated
    USING (
        is_super_admin(auth.uid()) OR
        has_permission('leads', 'view') OR
        showroom_id IN (SELECT get_user_showroom_ids(auth.uid())) OR
        assigned_to = auth.uid()
    );

CREATE POLICY "Authorized users can manage leads"
    ON public.leads FOR ALL
    TO authenticated
    USING (
        is_super_admin(auth.uid()) OR
        has_permission('leads', 'edit') OR
        has_permission('leads', 'create') OR
        assigned_to = auth.uid()
    );

-- Lead Activities RLS
CREATE POLICY "Users can view lead activities"
    ON public.lead_activities FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Authenticated users can create lead activities"
    ON public.lead_activities FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- Bookings RLS
CREATE POLICY "Users can view bookings in assigned showrooms"
    ON public.bookings FOR SELECT
    TO authenticated
    USING (
        is_super_admin(auth.uid()) OR
        has_permission('bookings', 'view') OR
        showroom_id IN (SELECT get_user_showroom_ids(auth.uid()))
    );

CREATE POLICY "Authorized users can manage bookings"
    ON public.bookings FOR ALL
    TO authenticated
    USING (
        is_super_admin(auth.uid()) OR
        has_permission('bookings', 'edit') OR
        has_permission('bookings', 'create')
    );
