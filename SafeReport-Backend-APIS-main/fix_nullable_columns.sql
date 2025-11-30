-- Fix Officer-specific columns to be NULLABLE for SINGLE_TABLE inheritance
-- Run this in pgAdmin for the SafeReport database

-- First, add dtype column if it doesn't exist
ALTER TABLE users ADD COLUMN IF NOT EXISTS dtype VARCHAR(31) DEFAULT 'User';

-- Update existing records to set dtype
UPDATE users SET dtype = 'User' WHERE dtype IS NULL;
UPDATE users SET dtype = 'Officer' WHERE badge_number IS NOT NULL OR officer_id IS NOT NULL;

-- Make dtype NOT NULL and set default
ALTER TABLE users ALTER COLUMN dtype SET NOT NULL;
ALTER TABLE users ALTER COLUMN dtype SET DEFAULT 'User';

-- Add Officer-specific columns if they don't exist (ALL NULLABLE!)
ALTER TABLE users ADD COLUMN IF NOT EXISTS latitude DOUBLE PRECISION;
ALTER TABLE users ADD COLUMN IF NOT EXISTS longitude DOUBLE PRECISION;
ALTER TABLE users ADD COLUMN IF NOT EXISTS officer_id VARCHAR(15);
ALTER TABLE users ADD COLUMN IF NOT EXISTS badge_number VARCHAR(255);
ALTER TABLE users ADD COLUMN IF NOT EXISTS officer_role_type VARCHAR(50);
ALTER TABLE users ADD COLUMN IF NOT EXISTS duty_status VARCHAR(50);
ALTER TABLE users ADD COLUMN IF NOT EXISTS backup_requested BOOLEAN DEFAULT FALSE;

-- CRITICAL: Drop NOT NULL constraints on Officer-specific columns
-- These MUST be nullable because regular User records won't have these values
ALTER TABLE users ALTER COLUMN latitude DROP NOT NULL;
ALTER TABLE users ALTER COLUMN longitude DROP NOT NULL;
ALTER TABLE users ALTER COLUMN officer_id DROP NOT NULL;
ALTER TABLE users ALTER COLUMN badge_number DROP NOT NULL;
ALTER TABLE users ALTER COLUMN officer_role_type DROP NOT NULL;
ALTER TABLE users ALTER COLUMN duty_status DROP NOT NULL;
ALTER TABLE users ALTER COLUMN backup_requested DROP NOT NULL;

-- Add unique constraints for officer-specific fields (only when not null)
CREATE UNIQUE INDEX IF NOT EXISTS idx_users_officer_id ON users(officer_id) WHERE officer_id IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS idx_users_badge_number ON users(badge_number) WHERE badge_number IS NOT NULL;

-- Verify the changes
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'users' 
ORDER BY column_name;

