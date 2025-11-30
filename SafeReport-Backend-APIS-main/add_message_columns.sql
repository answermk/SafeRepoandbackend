-- Migration script to add new columns to messages table
-- Run this script in your PostgreSQL database

-- Add attachment columns
ALTER TABLE messages 
ADD COLUMN IF NOT EXISTS attachment_url TEXT,
ADD COLUMN IF NOT EXISTS attachment_name VARCHAR(255),
ADD COLUMN IF NOT EXISTS attachment_type VARCHAR(100);

-- Add read receipt columns
ALTER TABLE messages 
ADD COLUMN IF NOT EXISTS is_read BOOLEAN NOT NULL DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS read_at TIMESTAMP;

-- Add edit/delete columns
ALTER TABLE messages 
ADD COLUMN IF NOT EXISTS is_edited BOOLEAN NOT NULL DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS edited_at TIMESTAMP,
ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP;

-- Update existing rows to have default values
UPDATE messages 
SET is_read = FALSE 
WHERE is_read IS NULL;

UPDATE messages 
SET is_edited = FALSE 
WHERE is_edited IS NULL;

UPDATE messages 
SET is_deleted = FALSE 
WHERE is_deleted IS NULL;

-- Verify the columns were added
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'messages'
ORDER BY ordinal_position;

