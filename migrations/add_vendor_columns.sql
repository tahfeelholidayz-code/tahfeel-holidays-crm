-- Add vendor columns to job table
-- Run this in Railway PostgreSQL console

-- Add vendor_id column
ALTER TABLE job ADD COLUMN IF NOT EXISTS vendor_id INTEGER;

-- Add vendor_amount column
ALTER TABLE job ADD COLUMN IF NOT EXISTS vendor_amount FLOAT DEFAULT 0;

-- Add vendor_paid column
ALTER TABLE job ADD COLUMN IF NOT EXISTS vendor_paid FLOAT DEFAULT 0;

-- Set default values for existing rows
UPDATE job SET vendor_amount = 0 WHERE vendor_amount IS NULL;
UPDATE job SET vendor_paid = 0 WHERE vendor_paid IS NULL;

-- Verify columns were added
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'job' 
AND column_name IN ('vendor_id', 'vendor_amount', 'vendor_paid');
