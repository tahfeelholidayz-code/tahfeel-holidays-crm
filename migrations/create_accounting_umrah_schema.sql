-- ============================================
-- ACCOUNTING & UMRAH MANAGEMENT SCHEMA
-- ============================================

-- 1. INVOICES TABLE
CREATE TABLE IF NOT EXISTS invoice (
    id SERIAL PRIMARY KEY,
    invoice_number VARCHAR(50) UNIQUE NOT NULL,
    customer_id INTEGER REFERENCES customer(id),
    task_id INTEGER REFERENCES job(id),  -- Optional link to task
    invoice_date DATE NOT NULL,
    due_date DATE,
    total_amount FLOAT NOT NULL DEFAULT 0,
    status VARCHAR(20) DEFAULT 'Draft',  -- Draft, Sent, Paid, Partially Paid, Cancelled
    notes TEXT,
    created_by INTEGER REFERENCES staff(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. INVOICE ITEMS TABLE (line items in invoice)
CREATE TABLE IF NOT EXISTS invoice_item (
    id SERIAL PRIMARY KEY,
    invoice_id INTEGER REFERENCES invoice(id) ON DELETE CASCADE,
    description TEXT NOT NULL,
    quantity INTEGER DEFAULT 1,
    unit_price FLOAT NOT NULL,
    amount FLOAT NOT NULL,  -- quantity * unit_price
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. RECEIPTS TABLE (Customer Payments)
CREATE TABLE IF NOT EXISTS receipt (
    id SERIAL PRIMARY KEY,
    receipt_number VARCHAR(50) UNIQUE NOT NULL,
    customer_id INTEGER REFERENCES customer(id),
    invoice_id INTEGER REFERENCES invoice(id),  -- Optional link to invoice
    amount FLOAT NOT NULL,
    payment_method VARCHAR(50),  -- Cash, Card, Bank Transfer, Cheque
    payment_date DATE NOT NULL,
    reference_number VARCHAR(100),  -- Bank ref, cheque no, etc
    notes TEXT,
    received_by INTEGER REFERENCES staff(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. EXPENSES TABLE (All Business Expenses)
CREATE TABLE IF NOT EXISTS expense (
    id SERIAL PRIMARY KEY,
    expense_number VARCHAR(50) UNIQUE NOT NULL,
    category VARCHAR(50) NOT NULL,  -- Vendor Payment, Office, Salary, Marketing, Other
    vendor_id INTEGER REFERENCES vendor(id),  -- For vendor payments
    task_id INTEGER REFERENCES job(id),  -- Optional link to task
    umrah_batch_id INTEGER,  -- Link to umrah batch (will add FK later)
    description TEXT NOT NULL,
    amount FLOAT NOT NULL,
    payment_method VARCHAR(50),
    payment_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'Paid',  -- Pending, Paid
    receipt_file VARCHAR(255),  -- Path to uploaded receipt
    notes TEXT,
    paid_by INTEGER REFERENCES staff(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. UMRAH BATCHES TABLE
CREATE TABLE IF NOT EXISTS umrah_batch (
    id SERIAL PRIMARY KEY,
    batch_number VARCHAR(50) UNIQUE NOT NULL,  -- UMR-2024-MAR-01
    batch_name VARCHAR(200),  -- e.g., "March 2024 Umrah Group"
    departure_date DATE NOT NULL,
    return_date DATE NOT NULL,
    hotel_name VARCHAR(200),
    hotel_makkah VARCHAR(200),
    hotel_madinah VARCHAR(200),
    flight_details TEXT,
    transport_details TEXT,
    total_capacity INTEGER DEFAULT 0,  -- Max customers
    total_cost FLOAT DEFAULT 0,  -- Total batch expense
    status VARCHAR(20) DEFAULT 'Planning',  -- Planning, Confirmed, In Progress, Completed, Cancelled
    notes TEXT,
    created_by INTEGER REFERENCES staff(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 6. UMRAH CUSTOMERS TABLE (Customers in each batch)
CREATE TABLE IF NOT EXISTS umrah_customer (
    id SERIAL PRIMARY KEY,
    batch_id INTEGER REFERENCES umrah_batch(id) ON DELETE CASCADE,
    customer_id INTEGER REFERENCES customer(id),
    task_id INTEGER REFERENCES job(id),  -- Optional link to task
    
    -- Passenger Details
    passenger_name VARCHAR(200) NOT NULL,
    passport_number VARCHAR(50),
    passport_expiry DATE,
    date_of_birth DATE,
    gender VARCHAR(10),
    nationality VARCHAR(50),
    
    -- Package & Pricing
    package_type VARCHAR(50),  -- Economy, VIP, Premium, etc
    package_price FLOAT NOT NULL DEFAULT 0,
    advance_paid FLOAT DEFAULT 0,
    balance_pending FLOAT DEFAULT 0,
    
    -- Individual Costs (expenses for this customer)
    visa_cost FLOAT DEFAULT 0,
    hotel_cost FLOAT DEFAULT 0,
    flight_cost FLOAT DEFAULT 0,
    transport_cost FLOAT DEFAULT 0,
    misc_cost FLOAT DEFAULT 0,
    total_cost FLOAT DEFAULT 0,  -- Sum of all costs
    
    -- Calculated
    profit FLOAT DEFAULT 0,  -- package_price - total_cost
    
    status VARCHAR(20) DEFAULT 'Registered',  -- Registered, Confirmed, Completed, Cancelled
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Add foreign key for umrah_batch_id in expense table
ALTER TABLE expense ADD CONSTRAINT fk_expense_umrah_batch 
    FOREIGN KEY (umrah_batch_id) REFERENCES umrah_batch(id) ON DELETE SET NULL;

-- ============================================
-- INDEXES for performance
-- ============================================
CREATE INDEX idx_invoice_customer ON invoice(customer_id);
CREATE INDEX idx_invoice_date ON invoice(invoice_date);
CREATE INDEX idx_invoice_status ON invoice(status);

CREATE INDEX idx_receipt_customer ON receipt(customer_id);
CREATE INDEX idx_receipt_invoice ON receipt(invoice_id);
CREATE INDEX idx_receipt_date ON receipt(payment_date);

CREATE INDEX idx_expense_category ON expense(category);
CREATE INDEX idx_expense_vendor ON expense(vendor_id);
CREATE INDEX idx_expense_date ON expense(payment_date);
CREATE INDEX idx_expense_batch ON expense(umrah_batch_id);

CREATE INDEX idx_umrah_batch_departure ON umrah_batch(departure_date);
CREATE INDEX idx_umrah_batch_status ON umrah_batch(status);

CREATE INDEX idx_umrah_customer_batch ON umrah_customer(batch_id);
CREATE INDEX idx_umrah_customer_customer ON umrah_customer(customer_id);

-- ============================================
-- SAMPLE DATA (for testing)
-- ============================================

-- Sample invoice sequence
CREATE SEQUENCE IF NOT EXISTS invoice_seq START 1;
CREATE SEQUENCE IF NOT EXISTS receipt_seq START 1;
CREATE SEQUENCE IF NOT EXISTS expense_seq START 1;
CREATE SEQUENCE IF NOT EXISTS umrah_batch_seq START 1;

-- ============================================
-- VERIFICATION QUERIES
-- ============================================
-- Run these to verify tables were created:

-- SELECT table_name FROM information_schema.tables 
-- WHERE table_schema = 'public' 
-- AND table_name IN ('invoice', 'invoice_item', 'receipt', 'expense', 'umrah_batch', 'umrah_customer')
-- ORDER BY table_name;

-- SELECT column_name, data_type FROM information_schema.columns 
-- WHERE table_name = 'umrah_customer' 
-- ORDER BY ordinal_position;
