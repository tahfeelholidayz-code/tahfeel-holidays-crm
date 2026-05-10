-- ============================================
-- NEW UMRAH MANAGEMENT SCHEMA
-- (Replaces previous umrah tables)
-- ============================================

-- Drop old tables if they exist
DROP TABLE IF EXISTS umrah_customer CASCADE;
DROP TABLE IF EXISTS umrah_batch CASCADE;

-- 1. UMRAH BOOKINGS (Main booking record)
CREATE TABLE IF NOT EXISTS umrah_booking (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customer(id),  -- Link to existing customer (optional)
    
    -- Booking summary
    adults_count INTEGER NOT NULL DEFAULT 0,
    children_count INTEGER NOT NULL DEFAULT 0,
    total_people INTEGER NOT NULL DEFAULT 0,
    
    -- Pricing
    adult_price FLOAT NOT NULL DEFAULT 0,  -- Price per adult
    child_price FLOAT NOT NULL DEFAULT 0,  -- Price per child
    total_package_amount FLOAT NOT NULL DEFAULT 0,  -- Total for all people
    amount_received FLOAT DEFAULT 0,
    balance_pending FLOAT DEFAULT 0,
    
    -- Batch assignment
    batch_id INTEGER,  -- Will add FK after batch table created
    status VARCHAR(50) DEFAULT 'Not Assigned',  -- Not Assigned, In Batch, Completed
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. UMRAH PASSENGERS (People in each booking)
CREATE TABLE IF NOT EXISTS umrah_passenger (
    id SERIAL PRIMARY KEY,
    booking_id INTEGER REFERENCES umrah_booking(id) ON DELETE CASCADE,
    
    -- Personal details
    passenger_name VARCHAR(200) NOT NULL,
    phone_number VARCHAR(50) NOT NULL,
    email VARCHAR(200),
    emergency_contact VARCHAR(50) NOT NULL,
    passport_number VARCHAR(50) NOT NULL,
    address TEXT NOT NULL,
    age INTEGER,
    passenger_type VARCHAR(10) NOT NULL,  -- Adult, Child
    gender VARCHAR(10) NOT NULL,  -- Male, Female
    is_primary BOOLEAN DEFAULT FALSE,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. UMRAH BATCHES
CREATE TABLE IF NOT EXISTS umrah_batch (
    id SERIAL PRIMARY KEY,
    batch_number VARCHAR(50) UNIQUE NOT NULL,
    batch_name VARCHAR(200),
    batch_type VARCHAR(20) NOT NULL,  -- Own Trip, Third Party
    
    -- Third party details
    third_party_agency VARCHAR(200),
    
    -- Trip details
    departure_date DATE,
    return_date DATE,
    hotel_makkah VARCHAR(200),
    hotel_madinah VARCHAR(200),
    flight_details TEXT,
    transport_details TEXT,
    
    -- Status
    status VARCHAR(20) DEFAULT 'Planning',  -- Planning, Confirmed, In Progress, Completed, Cancelled
    notes TEXT,
    
    created_by INTEGER REFERENCES staff(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Add FK for batch_id in umrah_booking
ALTER TABLE umrah_booking 
ADD CONSTRAINT fk_booking_batch 
FOREIGN KEY (batch_id) REFERENCES umrah_batch(id) ON DELETE SET NULL;

-- 4. BATCH EXPENSES (for Own Trip batches)
CREATE TABLE IF NOT EXISTS umrah_batch_expense (
    id SERIAL PRIMARY KEY,
    batch_id INTEGER REFERENCES umrah_batch(id) ON DELETE CASCADE,
    expense_type VARCHAR(100) NOT NULL,  -- Bus, Hotel Makkah, Hotel Madinah, Visa, Leader, Misc
    amount FLOAT NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. THIRD PARTY DETAILS (for Third Party batches)
CREATE TABLE IF NOT EXISTS umrah_third_party_detail (
    id SERIAL PRIMARY KEY,
    batch_id INTEGER REFERENCES umrah_batch(id) ON DELETE CASCADE,
    booking_id INTEGER REFERENCES umrah_booking(id) ON DELETE CASCADE,
    
    charged_to_customer FLOAT NOT NULL DEFAULT 0,
    given_to_agency FLOAT NOT NULL DEFAULT 0,
    we_keep FLOAT NOT NULL DEFAULT 0,
    revenue FLOAT NOT NULL DEFAULT 0,  -- Same as we_keep
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 6. PAYMENT HISTORY (track multiple payments per booking)
CREATE TABLE IF NOT EXISTS umrah_payment (
    id SERIAL PRIMARY KEY,
    booking_id INTEGER REFERENCES umrah_booking(id) ON DELETE CASCADE,
    amount FLOAT NOT NULL,
    payment_date DATE NOT NULL,
    payment_method VARCHAR(50),  -- Cash, Card, Bank Transfer
    notes TEXT,
    received_by INTEGER REFERENCES staff(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- INDEXES
-- ============================================
CREATE INDEX idx_umrah_booking_customer ON umrah_booking(customer_id);
CREATE INDEX idx_umrah_booking_batch ON umrah_booking(batch_id);
CREATE INDEX idx_umrah_booking_status ON umrah_booking(status);

CREATE INDEX idx_umrah_passenger_booking ON umrah_passenger(booking_id);
CREATE INDEX idx_umrah_passenger_primary ON umrah_passenger(is_primary);

CREATE INDEX idx_umrah_batch_type ON umrah_batch(batch_type);
CREATE INDEX idx_umrah_batch_status ON umrah_batch(status);
CREATE INDEX idx_umrah_batch_departure ON umrah_batch(departure_date);

CREATE INDEX idx_umrah_expense_batch ON umrah_batch_expense(batch_id);
CREATE INDEX idx_umrah_third_party_batch ON umrah_third_party_detail(batch_id);
CREATE INDEX idx_umrah_third_party_booking ON umrah_third_party_detail(booking_id);
CREATE INDEX idx_umrah_payment_booking ON umrah_payment(booking_id);

-- ============================================
-- VERIFICATION
-- ============================================
-- SELECT table_name FROM information_schema.tables 
-- WHERE table_schema = 'public' 
-- AND table_name LIKE 'umrah%'
-- ORDER BY table_name;
