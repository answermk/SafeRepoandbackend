-- Add officer_id column to officers table
ALTER TABLE officers ADD COLUMN officer_id VARCHAR(15) UNIQUE;

-- Create index for better performance
CREATE INDEX idx_officers_officer_id ON officers(officer_id);

-- Note: Existing officers will need to have their officer_id populated
-- This should be done through the application logic when they are first updated
