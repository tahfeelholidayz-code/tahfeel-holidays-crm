-- Add expanded visa tracking fields to job table
ALTER TABLE job ADD COLUMN IF NOT EXISTS visa_reference VARCHAR(100);
ALTER TABLE job ADD COLUMN IF NOT EXISTS visa_uid_no VARCHAR(100);
ALTER TABLE job ADD COLUMN IF NOT EXISTS visa_passport_no VARCHAR(100);
ALTER TABLE job ADD COLUMN IF NOT EXISTS visa_dob DATE;
ALTER TABLE job ADD COLUMN IF NOT EXISTS visa_contact_number_2 VARCHAR(50);
ALTER TABLE job ADD COLUMN IF NOT EXISTS visa_vendor VARCHAR(200);
ALTER TABLE job ADD COLUMN IF NOT EXISTS visa_notes TEXT;

-- Verify new columns were added
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'job' 
AND column_name LIKE 'visa%'
ORDER BY column_name;
