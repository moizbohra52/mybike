-- ============================================================================
-- Phase 11: Sales, Invoicing & Delivery Management
-- Indian Dealership CRM: Sales Invoices, Line Items, Payment Receipts,
-- Delivery Challans & Vehicle Gate Passes
-- ============================================================================

-- 1. Sales Invoices (GST Compliant Tax Invoices)
CREATE TABLE IF NOT EXISTS public.sales_invoices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    showroom_id UUID NOT NULL REFERENCES public.showrooms(id) ON DELETE RESTRICT,
    customer_id UUID NOT NULL REFERENCES public.customers(id) ON DELETE RESTRICT,
    booking_id UUID REFERENCES public.bookings(id) ON DELETE SET NULL,
    vehicle_inventory_id UUID REFERENCES public.inventory_vehicles(id) ON DELETE RESTRICT,
    invoice_number VARCHAR(30) NOT NULL UNIQUE, -- e.g. "IND-MUM-INV-00185"
    invoice_date DATE NOT NULL DEFAULT CURRENT_DATE,
    
    -- Vehicle Particulars
    variant_id UUID NOT NULL REFERENCES public.vehicle_variants(id) ON DELETE RESTRICT,
    color_id UUID NOT NULL REFERENCES public.vehicle_colors(id) ON DELETE RESTRICT,
    vin VARCHAR(17) NOT NULL,
    engine_number VARCHAR(50),
    motor_number VARCHAR(50),
    battery_serial_number VARCHAR(50),
    key_number VARCHAR(30),

    -- GST & Tax Particulars (Indian Dealership Standard)
    hsn_code VARCHAR(10) NOT NULL DEFAULT '8711', -- Two-wheelers HSN
    gst_rate NUMERIC(5,2) NOT NULL DEFAULT 28.00, -- 28% for ICE, 5% for EV
    is_interstate BOOLEAN NOT NULL DEFAULT false,
    
    -- Price Breakdown
    ex_showroom_price NUMERIC(12,2) NOT NULL,
    discount_amount NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    taxable_amount NUMERIC(12,2) NOT NULL,
    cgst_amount NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    sgst_amount NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    igst_amount NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    rto_charges NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    insurance_charges NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    accessories_total NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    extended_warranty_amount NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    fastag_charges NUMERIC(8,2) NOT NULL DEFAULT 0.00,
    hypothecation_charges NUMERIC(8,2) NOT NULL DEFAULT 0.00,
    tcs_amount NUMERIC(8,2) NOT NULL DEFAULT 0.00,
    round_off NUMERIC(6,2) NOT NULL DEFAULT 0.00,
    total_on_road_price NUMERIC(12,2) NOT NULL,

    -- Settlement / Payment
    booking_advance_adjusted NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    finance_amount NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    finance_bank VARCHAR(100),
    exchange_allowance NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    amount_paid NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    balance_amount NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    payment_status VARCHAR(20) NOT NULL DEFAULT 'pending'
        CHECK (payment_status IN ('pending', 'partial', 'paid', 'refunded')),

    -- Document State
    status VARCHAR(20) NOT NULL DEFAULT 'draft'
        CHECK (status IN ('draft', 'issued', 'delivered', 'cancelled')),
    issued_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER trigger_sales_invoices_updated_at
    BEFORE UPDATE ON public.sales_invoices
    FOR EACH ROW
    EXECUTE FUNCTION handle_updated_at();

-- 2. Invoice Line Items (Accessories, Warranty, Services)
CREATE TABLE IF NOT EXISTS public.invoice_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    invoice_id UUID NOT NULL REFERENCES public.sales_invoices(id) ON DELETE CASCADE,
    item_type VARCHAR(30) NOT NULL
        CHECK (item_type IN ('vehicle', 'accessory', 'insurance', 'rto', 'warranty', 'fastag', 'service', 'other')),
    item_code VARCHAR(50),
    description VARCHAR(200) NOT NULL,
    hsn_sac_code VARCHAR(10),
    quantity INT NOT NULL DEFAULT 1,
    unit_price NUMERIC(10,2) NOT NULL,
    discount_amount NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    gst_rate NUMERIC(5,2) NOT NULL DEFAULT 18.00,
    taxable_amount NUMERIC(10,2) NOT NULL,
    tax_amount NUMERIC(10,2) NOT NULL,
    total_amount NUMERIC(10,2) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3. Payment Receipts
CREATE TABLE IF NOT EXISTS public.payment_receipts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    showroom_id UUID NOT NULL REFERENCES public.showrooms(id) ON DELETE RESTRICT,
    customer_id UUID NOT NULL REFERENCES public.customers(id) ON DELETE RESTRICT,
    invoice_id UUID REFERENCES public.sales_invoices(id) ON DELETE SET NULL,
    booking_id UUID REFERENCES public.bookings(id) ON DELETE SET NULL,
    receipt_number VARCHAR(30) NOT NULL UNIQUE, -- e.g. "IND-MUM-RCP-00042"
    receipt_date DATE NOT NULL DEFAULT CURRENT_DATE,
    amount NUMERIC(12,2) NOT NULL,
    payment_mode VARCHAR(20) NOT NULL
        CHECK (payment_mode IN ('cash', 'upi', 'neft_rtgs', 'card', 'cheque', 'finance_disbursement', 'exchange_credit')),
    payment_reference VARCHAR(100),
    bank_name VARCHAR(100),
    collected_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 4. Delivery Challans
CREATE TABLE IF NOT EXISTS public.delivery_challans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    showroom_id UUID NOT NULL REFERENCES public.showrooms(id) ON DELETE RESTRICT,
    invoice_id UUID NOT NULL REFERENCES public.sales_invoices(id) ON DELETE RESTRICT,
    challan_number VARCHAR(30) NOT NULL UNIQUE, -- e.g. "IND-MUM-DC-00042"
    challan_date TIMESTAMPTZ NOT NULL DEFAULT now(),
    
    -- Handover Particulars
    allocated_vin VARCHAR(17) NOT NULL,
    odometer_reading_km NUMERIC(6,1) NOT NULL DEFAULT 0.0,
    battery_soc_percent NUMERIC(5,2), -- For EV
    fuel_level VARCHAR(20), -- For Petrol

    -- Mandated Delivery Checklist (Motor Vehicles Act compliance)
    helmet_provided BOOLEAN NOT NULL DEFAULT true,
    toolkit_provided BOOLEAN NOT NULL DEFAULT true,
    first_aid_kit_provided BOOLEAN NOT NULL DEFAULT true,
    owner_manual_provided BOOLEAN NOT NULL DEFAULT true,
    spare_keys_count INT NOT NULL DEFAULT 2,
    battery_charger_serial VARCHAR(50), -- EV
    pdi_form_signed BOOLEAN NOT NULL DEFAULT true,
    customer_acceptance_signed BOOLEAN NOT NULL DEFAULT true,

    delivered_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    received_by_name VARCHAR(100) NOT NULL,
    received_by_relationship VARCHAR(50) DEFAULT 'self',
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 5. Gate Passes (Exit Security Clearance)
CREATE TABLE IF NOT EXISTS public.gate_passes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    showroom_id UUID NOT NULL REFERENCES public.showrooms(id) ON DELETE RESTRICT,
    challan_id UUID NOT NULL REFERENCES public.delivery_challans(id) ON DELETE RESTRICT,
    invoice_id UUID NOT NULL REFERENCES public.sales_invoices(id) ON DELETE RESTRICT,
    gate_pass_number VARCHAR(30) NOT NULL UNIQUE, -- e.g. "IND-MUM-GP-00042"
    issued_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    
    vin VARCHAR(17) NOT NULL,
    customer_name VARCHAR(100) NOT NULL,
    authorized_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    security_guard_name VARCHAR(100),
    vehicle_departed_at TIMESTAMPTZ,
    status VARCHAR(20) NOT NULL DEFAULT 'issued'
        CHECK (status IN ('issued', 'departed', 'void')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Indexes for optimal query performance
CREATE INDEX IF NOT EXISTS idx_sales_invoices_showroom ON public.sales_invoices(showroom_id);
CREATE INDEX IF NOT EXISTS idx_sales_invoices_customer ON public.sales_invoices(customer_id);
CREATE INDEX IF NOT EXISTS idx_sales_invoices_status ON public.sales_invoices(status);
CREATE INDEX IF NOT EXISTS idx_sales_invoices_vin ON public.sales_invoices(vin);
CREATE INDEX IF NOT EXISTS idx_invoice_items_invoice ON public.invoice_items(invoice_id);
CREATE INDEX IF NOT EXISTS idx_payment_receipts_invoice ON public.payment_receipts(invoice_id);
CREATE INDEX IF NOT EXISTS idx_payment_receipts_customer ON public.payment_receipts(customer_id);
CREATE INDEX IF NOT EXISTS idx_delivery_challans_invoice ON public.delivery_challans(invoice_id);
CREATE INDEX IF NOT EXISTS idx_gate_passes_challan ON public.gate_passes(challan_id);

-- Row-Level Security
ALTER TABLE public.sales_invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.invoice_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_receipts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.delivery_challans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gate_passes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow authenticated full access to sales_invoices"
    ON public.sales_invoices FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Allow authenticated full access to invoice_items"
    ON public.invoice_items FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Allow authenticated full access to payment_receipts"
    ON public.payment_receipts FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Allow authenticated full access to delivery_challans"
    ON public.delivery_challans FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Allow authenticated full access to gate_passes"
    ON public.gate_passes FOR ALL TO authenticated USING (true) WITH CHECK (true);
