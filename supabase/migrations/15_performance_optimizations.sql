-- =====================================================================
-- Migration 15: Performance Optimizations & Query Indexing
-- MYBIKE Enterprise Multi-Showroom Two-Wheeler ERP
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Composite Indexes on High-Frequency Multi-Tenant Queries
-- ---------------------------------------------------------------------

-- Sales Invoices: Filtered by showroom and sorted by date
CREATE INDEX IF NOT EXISTS idx_sales_invoices_showroom_date 
  ON sales_invoices(showroom_id, invoice_date DESC);

-- Sales Invoices: Filtered by showroom and payment / invoice status
CREATE INDEX IF NOT EXISTS idx_sales_invoices_showroom_status 
  ON sales_invoices(showroom_id, status);

-- Bookings: Filtered by showroom and sorted by booking date
CREATE INDEX IF NOT EXISTS idx_bookings_showroom_date 
  ON bookings(showroom_id, booking_date DESC);

-- Bookings: Filtered by showroom and lifecycle status
CREATE INDEX IF NOT EXISTS idx_bookings_showroom_status 
  ON bookings(showroom_id, booking_status);

-- Inventory Items: Filtered by showroom, stock status, and vehicle model
CREATE INDEX IF NOT EXISTS idx_inventory_showroom_status_model 
  ON inventory_items(showroom_id, status, model_id);

-- Customers: Filtered by showroom and sorted by creation date
CREATE INDEX IF NOT EXISTS idx_customers_showroom_created 
  ON customers(showroom_id, created_at DESC);

-- Finance Vouchers: Filtered by showroom and sorted by voucher date
CREATE INDEX IF NOT EXISTS idx_finance_vouchers_showroom_date 
  ON finance_vouchers(showroom_id, voucher_date DESC);

-- General Ledger: Filtered by showroom and transaction date
CREATE INDEX IF NOT EXISTS idx_general_ledger_showroom_date 
  ON general_ledger(showroom_id, transaction_date DESC);

-- Dealership Documents: Filtered by showroom and sorted by creation date
CREATE INDEX IF NOT EXISTS idx_documents_showroom_created 
  ON dealership_documents(showroom_id, created_at DESC);

-- Approval Requests: Filtered by showroom, status, and sorted by creation date
CREATE INDEX IF NOT EXISTS idx_approvals_showroom_status_created 
  ON approval_requests(showroom_id, status, created_at DESC);

-- Audit Logs: Filtered by showroom and sorted by timestamp
CREATE INDEX IF NOT EXISTS idx_audit_showroom_timestamp 
  ON audit_logs(showroom_id, timestamp DESC);

-- Notifications: Filtered by user and read status
CREATE INDEX IF NOT EXISTS idx_notifications_user_unread 
  ON notifications(user_id, is_read, created_at DESC);

-- ---------------------------------------------------------------------
-- 2. Partial Indexes for High-Velocity Filter States
-- ---------------------------------------------------------------------

-- Pending Approval Requests: Critical for executive dashboard badges
CREATE INDEX IF NOT EXISTS idx_approvals_pending 
  ON approval_requests(showroom_id, created_at DESC) 
  WHERE status = 'pending';

-- Active Bookings awaiting delivery / allotment
CREATE INDEX IF NOT EXISTS idx_bookings_active 
  ON bookings(showroom_id, booking_date DESC) 
  WHERE booking_status IN ('confirmed', 'allotted');

-- In-Stock Inventory lookup
CREATE INDEX IF NOT EXISTS idx_inventory_in_stock 
  ON inventory_items(showroom_id, model_id) 
  WHERE status = 'in_stock';

-- ---------------------------------------------------------------------
-- 3. Lookup & Search B-Tree Indexes
-- ---------------------------------------------------------------------

-- Fast VIN & Engine lookup on vehicle inventory
CREATE INDEX IF NOT EXISTS idx_inventory_vin 
  ON inventory_items(vin);

CREATE INDEX IF NOT EXISTS idx_inventory_engine 
  ON inventory_items(engine_number);

-- Fast customer phone lookup for CRM / bookings
CREATE INDEX IF NOT EXISTS idx_customers_phone 
  ON customers(phone);

-- Invoice & Booking reference lookups
CREATE INDEX IF NOT EXISTS idx_sales_invoices_no 
  ON sales_invoices(invoice_number);

CREATE INDEX IF NOT EXISTS idx_bookings_no 
  ON bookings(booking_number);

-- Document entity association lookup
CREATE INDEX IF NOT EXISTS idx_documents_entity 
  ON dealership_documents(entity_type, entity_id);

-- General Ledger account code lookup
CREATE INDEX IF NOT EXISTS idx_general_ledger_account 
  ON general_ledger(account_id, transaction_date DESC);
