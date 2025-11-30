-- Sample Data for Crime Prevention Backend
-- Run this script to populate your database with test data

-- 1. Insert sample locations
INSERT INTO locations (id, address, district, sector, zone, latitude, longitude, is_active, created_at, updated_at) VALUES
('550e8400-e29b-41d4-a716-446655440001', '123 Main Street', 'Central District', 'Downtown', 'Zone A', -1.9441, 30.0619, true, NOW(), NOW()),
('550e8400-e29b-41d4-a716-446655440002', '456 Oak Avenue', 'North District', 'Residential', 'Zone B', -1.9442, 30.0620, true, NOW(), NOW()),
('550e8400-e29b-41d4-a716-446655440003', '789 Pine Road', 'South District', 'Commercial', 'Zone C', -1.9443, 30.0621, true, NOW(), NOW()),
('550e8400-e29b-41d4-a716-446655440004', '321 Elm Street', 'East District', 'Industrial', 'Zone D', -1.9444, 30.0622, true, NOW(), NOW()),
('550e8400-e29b-41d4-a716-446655440005', '654 Maple Drive', 'West District', 'Suburban', 'Zone E', -1.9445, 30.0623, true, NOW(), NOW());

-- 2. Insert sample crime types
INSERT INTO crime_types (id, name) VALUES
('660e8400-e29b-41d4-a716-446655440001', 'Theft'),
('660e8400-e29b-41d4-a716-446655440002', 'Assault'),
('660e8400-e29b-41d4-a716-446655440003', 'Vandalism'),
('660e8400-e29b-41d4-a716-446655440004', 'Fraud'),
('660e8400-e29b-41d4-a716-446655440005', 'Burglary'),
('660e8400-e29b-41d4-a716-446655440006', 'Robbery'),
('660e8400-e29b-41d4-a716-446655440007', 'Drug Offense'),
('660e8400-e29b-41d4-a716-446655440008', 'Traffic Violation');

-- 3. Insert sample weather conditions
INSERT INTO weather_conditions (id, condition) VALUES
('770e8400-e29b-41d4-a716-446655440001', 'Clear'),
('770e8400-e29b-41d4-a716-446655440002', 'Cloudy'),
('770e8400-e29b-41d4-a716-446655440003', 'Rainy'),
('770e8400-e29b-41d4-a716-446655440004', 'Foggy'),
('770e8400-e29b-41d4-a716-446655440005', 'Stormy'),
('770e8400-e29b-41d4-a716-446655440006', 'Windy'),
('770e8400-e29b-41d4-a716-446655440007', 'Snowy');

-- 4. Create Officer Smith's officer record (ON_DUTY role)
INSERT INTO officers (id, role_type, duty_status, backup_requested, is_active, created_at, updated_at) VALUES
('aeea2828-93d6-4b49-bcec-83e08d637465', 'ON_DUTY', 'AVAILABLE', false, true, NOW(), NOW());

-- Display the inserted data
SELECT 'Locations' as table_name, COUNT(*) as count FROM locations
UNION ALL
SELECT 'Crime Types', COUNT(*) FROM crime_types
UNION ALL
SELECT 'Weather Conditions', COUNT(*) FROM weather_conditions
UNION ALL
SELECT 'Officers', COUNT(*) FROM officers;

-- Note: Sample reports, media, and assignments are not inserted to avoid foreign key constraint issues
-- You can create reports through the API once the reference data is in place 