-- ============================================================================
-- MYBIKE ERP — Phase 8: Vehicle Master Schema Migration
-- ============================================================================
-- Description: Brands, Vehicle Models, Variants (Petrol & EV specifications),
--              Commercial on-road pricing, and Color options.
-- ============================================================================

-- 1. Brands Table
CREATE TABLE IF NOT EXISTS public.brands (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE,
    code VARCHAR(50) NOT NULL UNIQUE,
    country_of_origin VARCHAR(50) DEFAULT 'India',
    logo_url TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER trigger_brands_updated_at
    BEFORE UPDATE ON public.brands
    FOR EACH ROW
    EXECUTE FUNCTION handle_updated_at();

-- 2. Vehicle Models Table
CREATE TABLE IF NOT EXISTS public.vehicle_models (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    brand_id UUID NOT NULL REFERENCES public.brands(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    code VARCHAR(50) NOT NULL,
    type VARCHAR(20) NOT NULL CHECK (type IN ('petrol', 'electric')),
    body_type VARCHAR(30) NOT NULL DEFAULT 'motorcycle', -- motorcycle, scooter, cruiser, sports, commuter, adventure
    description TEXT,
    image_url TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_brand_model_code UNIQUE (brand_id, code)
);

CREATE TRIGGER trigger_vehicle_models_updated_at
    BEFORE UPDATE ON public.vehicle_models
    FOR EACH ROW
    EXECUTE FUNCTION handle_updated_at();

-- 3. Vehicle Variants Table (Specs & Pricing)
CREATE TABLE IF NOT EXISTS public.vehicle_variants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    model_id UUID NOT NULL REFERENCES public.vehicle_models(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    code VARCHAR(50) NOT NULL,
    fuel_type VARCHAR(20) NOT NULL CHECK (fuel_type IN ('petrol', 'electric')),

    -- Petrol Specifications
    engine_capacity_cc NUMERIC(6,2),
    max_power_bhp NUMERIC(6,2),
    max_torque_nm NUMERIC(6,2),
    mileage_kmpl NUMERIC(5,2),
    fuel_tank_capacity_l NUMERIC(5,2),
    transmission VARCHAR(30), -- e.g. 5-Speed Manual, Automatic CVT
    emission_norm VARCHAR(30) DEFAULT 'BS6 Phase 2',

    -- Electric (EV) Specifications
    battery_capacity_kwh NUMERIC(5,2),
    motor_power_kw NUMERIC(5,2),
    certified_range_km INT,
    true_range_km INT,
    charging_time_hours NUMERIC(4,2),
    fast_charging_support BOOLEAN DEFAULT false,
    battery_warranty_years INT DEFAULT 3,

    -- Common Technical Specifications
    front_brake VARCHAR(50) DEFAULT 'Disc',
    rear_brake VARCHAR(50) DEFAULT 'Disc',
    abs_type VARCHAR(50) DEFAULT 'Single Channel ABS',
    kerb_weight_kg NUMERIC(6,2),
    seat_height_mm INT,
    ground_clearance_mm INT,

    -- Commercial & Statutory Pricing (INR)
    ex_showroom_price NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    gst_rate_percent NUMERIC(4,2) NOT NULL DEFAULT 28.00, -- 28% petrol, 5% EV
    cess_percent NUMERIC(4,2) NOT NULL DEFAULT 0.00,       -- 3% for petrol > 350cc
    rto_charges NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    insurance_charges NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    handling_charges NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    standard_accessories_price NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    extended_warranty_price NUMERIC(10,2) NOT NULL DEFAULT 0.00,

    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_model_variant_code UNIQUE (model_id, code)
);

CREATE TRIGGER trigger_vehicle_variants_updated_at
    BEFORE UPDATE ON public.vehicle_variants
    FOR EACH ROW
    EXECUTE FUNCTION handle_updated_at();

-- 4. Vehicle Colors Table
CREATE TABLE IF NOT EXISTS public.vehicle_colors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    variant_id UUID NOT NULL REFERENCES public.vehicle_variants(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    hex_code VARCHAR(10) NOT NULL DEFAULT '#000000',
    image_url TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 5. Indexes for fast lookup
CREATE INDEX IF NOT EXISTS idx_vehicle_models_brand ON public.vehicle_models(brand_id);
CREATE INDEX IF NOT EXISTS idx_vehicle_models_type ON public.vehicle_models(type);
CREATE INDEX IF NOT EXISTS idx_vehicle_variants_model ON public.vehicle_variants(model_id);
CREATE INDEX IF NOT EXISTS idx_vehicle_colors_variant ON public.vehicle_colors(variant_id);

-- 6. Row Level Security Policies
ALTER TABLE public.brands ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vehicle_models ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vehicle_variants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vehicle_colors ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow authenticated read brands"
    ON public.brands FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Allow authenticated read vehicle_models"
    ON public.vehicle_models FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Allow authenticated read vehicle_variants"
    ON public.vehicle_variants FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Allow authenticated read vehicle_colors"
    ON public.vehicle_colors FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Allow admin manage brands"
    ON public.brands FOR ALL
    TO authenticated
    USING (auth.jwt() ->> 'email' IN (SELECT email FROM public.profiles WHERE is_active = true));

CREATE POLICY "Allow admin manage vehicle_models"
    ON public.vehicle_models FOR ALL
    TO authenticated
    USING (auth.jwt() ->> 'email' IN (SELECT email FROM public.profiles WHERE is_active = true));

CREATE POLICY "Allow admin manage vehicle_variants"
    ON public.vehicle_variants FOR ALL
    TO authenticated
    USING (auth.jwt() ->> 'email' IN (SELECT email FROM public.profiles WHERE is_active = true));

CREATE POLICY "Allow admin manage vehicle_colors"
    ON public.vehicle_colors FOR ALL
    TO authenticated
    USING (auth.jwt() ->> 'email' IN (SELECT email FROM public.profiles WHERE is_active = true));
