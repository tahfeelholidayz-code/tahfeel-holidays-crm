-- Add revenue columns to job table
-- Run this in Railway PostgreSQL console

ALTER TABLE job ADD COLUMN IF NOT EXISTS revenue_amount FLOAT DEFAULT 0;
ALTER TABLE job ADD COLUMN IF NOT EXISTS revenue_date DATE;

-- Set default values for existing closed jobs
UPDATE job 
SET revenue_amount = 0 
WHERE revenue_amount IS NULL AND status = 'Closed';

-- Verify columns were added
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'job' 
AND column_name IN ('revenue_amount', 'revenue_date');
