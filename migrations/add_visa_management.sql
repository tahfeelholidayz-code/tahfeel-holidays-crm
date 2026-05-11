-- Add visa tracking fields to job table
ALTER TABLE job ADD COLUMN IF NOT EXISTS visa_expiry_date DATE;
ALTER TABLE job ADD COLUMN IF NOT EXISTS visa_customer_name VARCHAR(200);
ALTER TABLE job ADD COLUMN IF NOT EXISTS visa_customer_phone VARCHAR(50);
ALTER TABLE job ADD COLUMN IF NOT EXISTS visa_third_party_agency VARCHAR(200);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_job_visa_expiry ON job(visa_expiry_date) WHERE visa_expiry_date IS NOT NULL;

-- Verify columns were added
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'job' 
AND column_name LIKE 'visa%'
ORDER BY column_name;
