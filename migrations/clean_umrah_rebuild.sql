-- ============================================
-- CLEAN UMRAH SCHEMA REBUILD
-- Run this in Railway PostgreSQL Query
-- ============================================

-- Drop ALL umrah tables and related objects
DROP TABLE IF EXISTS umrah_payment CASCADE;
DROP TABLE IF EXISTS umrah_third_party_detail CASCADE;
DROP TABLE IF EXISTS umrah_batch_expense CASCADE;
DROP TABLE IF EXISTS umrah_passenger CASCADE;
DROP TABLE IF EXISTS umrah_booking CASCADE;
DROP TABLE IF EXISTS umrah_batch CASCADE;
DROP TABLE IF EXISTS umrah_customer CASCADE;

-- ============================================
-- REBUILD ALL TABLES
-- ============================================

-- 1. UMRAH BATCHES (create first for FK reference)
CREATE TABLE umrah_batch (
    id SERIAL PRIMARY KEY,
    batch_number VARCHAR(50) UNIQUE NOT NULL,
    batch_name VARCHAR(200),
    batch_type VARCHAR(20) NOT NULL,
    third_party_agency VARCHAR(200),
    departure_date DATE,
    return_date DATE,
    hotel_makkah VARCHAR(200),
    hotel_madinah VARCHAR(200),
    flight_details TEXT,
    transport_details TEXT,
    status VARCHAR(20) DEFAULT 'Planning',
    notes TEXT,
    created_by INTEGER REFERENCES staff(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. UMRAH BOOKINGS
CREATE TABLE umrah_booking (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customer(id),
    adults_count INTEGER NOT NULL DEFAULT 0,
    children_count INTEGER NOT NULL DEFAULT 0,
    total_people INTEGER NOT NULL DEFAULT 0,
    adult_price FLOAT NOT NULL DEFAULT 0,
    child_price FLOAT NOT NULL DEFAULT 0,
    total_package_amount FLOAT NOT NULL DEFAULT 0,
    amount_received FLOAT DEFAULT 0,
    balance_pending FLOAT DEFAULT 0,
    batch_id INTEGER REFERENCES umrah_batch(id) ON DELETE SET NULL,
    status VARCHAR(50) DEFAULT 'Not Assigned',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. UMRAH PASSENGERS
CREATE TABLE umrah_passenger (
    id SERIAL PRIMARY KEY,
    booking_id INTEGER REFERENCES umrah_booking(id) ON DELETE CASCADE,
    passenger_name VARCHAR(200) NOT NULL,
    phone_number VARCHAR(50) NOT NULL,
    email VARCHAR(200),
    emergency_contact VARCHAR(50) NOT NULL,
    passport_number VARCHAR(50) NOT NULL,
    address TEXT NOT NULL,
    age INTEGER,
    passenger_type VARCHAR(10) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. BATCH EXPENSES
CREATE TABLE umrah_batch_expense (
    id SERIAL PRIMARY KEY,
    batch_id INTEGER REFERENCES umrah_batch(id) ON DELETE CASCADE,
    expense_type VARCHAR(100) NOT NULL,
    amount FLOAT NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. THIRD PARTY DETAILS
CREATE TABLE umrah_third_party_detail (
    id SERIAL PRIMARY KEY,
    batch_id INTEGER REFERENCES umrah_batch(id) ON DELETE CASCADE,
    booking_id INTEGER REFERENCES umrah_booking(id) ON DELETE CASCADE,
    charged_to_customer FLOAT NOT NULL DEFAULT 0,
    given_to_agency FLOAT NOT NULL DEFAULT 0,
    we_keep FLOAT NOT NULL DEFAULT 0,
    revenue FLOAT NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 6. PAYMENT HISTORY
CREATE TABLE umrah_payment (
    id SERIAL PRIMARY KEY,
    booking_id INTEGER REFERENCES umrah_booking(id) ON DELETE CASCADE,
    amount FLOAT NOT NULL,
    payment_date DATE NOT NULL,
    payment_method VARCHAR(50),
    notes TEXT,
    received_by INTEGER REFERENCES staff(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- CREATE INDEXES
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
-- DONE! All tables created successfully
-- ============================================
