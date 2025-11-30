-- Add dtype column to users table for JPA inheritance
ALTER TABLE users ADD COLUMN IF NOT EXISTS dtype VARCHAR(31) DEFAULT 'User';

-- Update existing records
UPDATE users SET dtype = 'User' WHERE dtype IS NULL;

-- Update Officer records (if any exist in the officers table - though with SINGLE_TABLE they should be in users)
-- Note: With SINGLE_TABLE strategy, officers are stored in the users table
UPDATE users SET dtype = 'Officer' WHERE badge_number IS NOT NULL OR officer_id IS NOT NULL;

-- Make dtype NOT NULL after setting defaults
ALTER TABLE users ALTER COLUMN dtype SET NOT NULL;
