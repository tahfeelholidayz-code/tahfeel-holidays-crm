# DATABASE MIGRATION REQUIRED

## Problem
The vendor columns (vendor_id, vendor_amount, vendor_paid) are in the code but NOT in the Railway PostgreSQL database.

## Solution - Run SQL Migration

### Step 1: Access Railway PostgreSQL
1. Go to Railway Dashboard
2. Click on your PostgreSQL database
3. Click "Query" tab or "Data" tab
4. Open SQL console

### Step 2: Run Migration SQL
Copy and paste this SQL:

```sql
ALTER TABLE job ADD COLUMN IF NOT EXISTS vendor_id INTEGER;
ALTER TABLE job ADD COLUMN IF NOT EXISTS vendor_amount FLOAT DEFAULT 0;
ALTER TABLE job ADD COLUMN IF NOT EXISTS vendor_paid FLOAT DEFAULT 0;

UPDATE job SET vendor_amount = 0 WHERE vendor_amount IS NULL;
UPDATE job SET vendor_paid = 0 WHERE vendor_paid IS NULL;
```

### Step 3: Verify
Run this to check columns were added:

```sql
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'job' 
AND column_name IN ('vendor_id', 'vendor_amount', 'vendor_paid');
```

You should see 3 rows returned.

### Step 4: Redeploy
After running the SQL:
1. Go back to your Railway app
2. Click "Redeploy" or push this commit
3. Wait for deployment to complete
4. Hard refresh browser (Ctrl+Shift+R)

## What This Fixes
- ✅ Tasks page will load
- ✅ Can view task details
- ✅ Can add tasks with vendors
- ✅ Vendor page shows amounts correctly
- ✅ All pages work

## Files Included
- `/migrations/add_vendor_columns.sql` - SQL migration script
- This README with instructions
