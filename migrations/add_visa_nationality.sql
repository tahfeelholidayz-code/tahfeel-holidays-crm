-- Add nationality field to visa records
ALTER TABLE job ADD COLUMN IF NOT EXISTS visa_nationality VARCHAR(100);

-- Verify
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'job' 
AND column_name = 'visa_nationality';
