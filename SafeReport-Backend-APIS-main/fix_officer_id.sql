-- Fix officer_id column issue
-- Run this script if you're getting 500 errors when loading officers

-- Add officer_id column if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'officers' AND column_name = 'officer_id') THEN
        ALTER TABLE officers ADD COLUMN officer_id VARCHAR(15);
        CREATE INDEX idx_officers_officer_id ON officers(officer_id);
        RAISE NOTICE 'Added officer_id column to officers table';
    ELSE
        RAISE NOTICE 'officer_id column already exists';
    END IF;
END $$;

-- Check current state
SELECT COUNT(*) as total_officers, 
       COUNT(officer_id) as officers_with_id,
       COUNT(*) - COUNT(officer_id) as officers_without_id
FROM officers;
