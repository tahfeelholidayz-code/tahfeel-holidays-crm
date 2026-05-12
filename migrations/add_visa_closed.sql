-- Add visa_closed field to track closed visas
ALTER TABLE job ADD COLUMN IF NOT EXISTS visa_closed BOOLEAN DEFAULT FALSE;

-- Set all existing visas to not closed
UPDATE job SET visa_closed = FALSE WHERE visa_expiry_date IS NOT NULL AND visa_closed IS NULL;

-- Verify
SELECT COUNT(*) as total_visas, 
       SUM(CASE WHEN visa_closed = TRUE THEN 1 ELSE 0 END) as closed_visas,
       SUM(CASE WHEN visa_closed = FALSE OR visa_closed IS NULL THEN 1 ELSE 0 END) as active_visas
FROM job 
WHERE visa_expiry_date IS NOT NULL;
