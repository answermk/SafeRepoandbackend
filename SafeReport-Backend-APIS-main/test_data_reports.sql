-- =====================================================
-- TEST DATA: Crime Reports for Officer Testing
-- =====================================================
-- This script inserts realistic test crime reports into the database
-- for testing officer functionality without needing the mobile app.
--
-- Usage:
--   psql -U postgres -d SafeReport -f test_data_reports.sql
-- =====================================================

-- First, ensure we have test users (civilian reporters)
INSERT INTO users (id, full_name, email, phone_number, username, password_hash, role, enabled, is_active, dtype, created_at, updated_at)
VALUES 
  ('11111111-1111-1111-1111-111111111111', 'Sarah Johnson', 'sarah.j@email.com', '+250788123456', 'sarah.j', '$2a$10$dummyHashForTesting', 'CIVILIAN', true, true, 'User', NOW(), NOW()),
  ('22222222-2222-2222-2222-222222222222', 'Anonymous Neighbor', 'anon@test.com', '+250788555666', 'anon1', '$2a$10$dummyHashForTesting', 'CIVILIAN', true, true, 'User', NOW(), NOW()),
  ('33333333-3333-3333-3333-333333333333', 'Park Security', 'security@citypark.rw', '+250788777888', 'park.security', '$2a$10$dummyHashForTesting', 'CIVILIAN', true, true, 'User', NOW(), NOW()),
  ('44444444-4444-4444-4444-444444444444', 'David Mugisha', 'dmugisha@email.com', '+250788111000', 'dmugisha', '$2a$10$dummyHashForTesting', 'CIVILIAN', true, true, 'User', NOW(), NOW()),
  ('55555555-5555-5555-5555-555555555555', 'TechMart Electronics', 'security@techmart.rw', '+250788222111', 'techmart', '$2a$10$dummyHashForTesting', 'CIVILIAN', true, true, 'User', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- Get the first available officer ID (or use specific officer ID if you know it)
-- You may need to replace 'REPLACE_WITH_OFFICER_ID' with actual officer ID after creating one

-- =====================================================
-- ACTIVE CASES (Assigned to officers)
-- =====================================================

-- Case 1: Armed Robbery (CRITICAL)
INSERT INTO reports (
  id, title, description, crime_type, status, priority, severity,
  latitude, longitude, address, district, sector, cell,
  user_id, is_anonymous, officer_id,
  created_at, updated_at
)
VALUES (
  '91111111-1111-1111-1111-111111111111',
  'Armed Robbery - Downtown Bank',
  'Three masked individuals entered First National Bank at approximately 2:45 PM. Witnesses report they were armed with handguns. They fled the scene in a dark SUV heading north on Main Street. No injuries reported.',
  'ARMED_ROBBERY',
  'IN_PROGRESS',
  'CRITICAL',
  'HIGH',
  -1.9540, 30.0996,
  '234 Main Street, Downtown Financial District',
  'Gasabo', 'Kacyiru', 'Kamatamu',
  '11111111-1111-1111-1111-111111111111',
  false,
  NULL, -- Will be assigned by officer
  NOW() - INTERVAL '2 hours',
  NOW() - INTERVAL '1 hour'
);

-- Case 2: Domestic Violence (URGENT)
INSERT INTO reports (
  id, title, description, crime_type, status, priority, severity,
  latitude, longitude, address, district, sector, cell,
  user_id, is_anonymous, officer_id,
  created_at, updated_at
)
VALUES (
  '92222222-2222-2222-2222-222222222222',
  'Domestic Violence - Urgent Response Needed',
  'Neighbor reports hearing screaming and loud crashing sounds from apartment 3B. Female voice heard calling for help. Situation ongoing.',
  'DOMESTIC_VIOLENCE',
  'PENDING',
  'URGENT',
  'HIGH',
  -1.9562, 30.1015,
  '789 Residential Complex, Building A, Apt 3B',
  'Kicukiro', 'Gikondo', 'Gikondo',
  '22222222-2222-2222-2222-222222222222',
  true,
  NULL,
  NOW() - INTERVAL '30 minutes',
  NOW() - INTERVAL '30 minutes'
);

-- Case 3: Drug Dealing (HIGH)
INSERT INTO reports (
  id, title, description, crime_type, status, priority, severity,
  latitude, longitude, address, district, sector, cell,
  user_id, is_anonymous, officer_id,
  created_at, updated_at
)
VALUES (
  '93333333-3333-3333-3333-333333333333',
  'Drug Dealing - Park Surveillance',
  'Multiple reports of suspected drug dealing in City Park. Young individuals observed exchanging small packages for cash. Activity occurs mainly during evening hours 6-9 PM.',
  'DRUG_TRAFFICKING',
  'PENDING',
  'HIGH',
  'MEDIUM',
  -1.9548, 30.1003,
  'City Central Park, East Entrance',
  'Gasabo', 'Remera', 'Rukiri',
  '33333333-3333-3333-3333-333333333333',
  false,
  NULL,
  NOW() - INTERVAL '1 day',
  NOW() - INTERVAL '8 hours'
);

-- =====================================================
-- PENDING CASES (Waiting for assignment)
-- =====================================================

-- Case 4: Vehicle Theft (HIGH)
INSERT INTO reports (
  id, title, description, crime_type, status, priority, severity,
  latitude, longitude, address, district, sector, cell,
  user_id, is_anonymous, officer_id,
  created_at, updated_at
)
VALUES (
  '94444444-4444-4444-4444-444444444444',
  'Vehicle Theft - Residential Area',
  'Toyota Corolla (RAB 123C) stolen from resident''s driveway overnight. Vehicle was locked and parked in front of house. Security camera footage available.',
  'VEHICLE_THEFT',
  'PENDING',
  'HIGH',
  'MEDIUM',
  -1.9565, 30.1025,
  '456 Gishuushu Street, Kimironko',
  'Gasabo', 'Kimironko', 'Biryogo',
  '44444444-4444-4444-4444-444444444444',
  false,
  NULL,
  NOW() - INTERVAL '12 hours',
  NOW() - INTERVAL '12 hours'
);

-- Case 5: Burglary (URGENT)
INSERT INTO reports (
  id, title, description, crime_type, status, priority, severity,
  latitude, longitude, address, district, sector, cell,
  user_id, is_anonymous, officer_id,
  created_at, updated_at
)
VALUES (
  '95555555-5555-5555-5555-555555555555',
  'Burglary - Business Premises',
  'Break-in at electronics shop. Front window smashed, multiple items stolen including laptops, phones, and tablets. Alarm was triggered at 3:15 AM.',
  'BURGLARY',
  'PENDING',
  'URGENT',
  'HIGH',
  -1.9550, 30.1000,
  '123 Commercial Street, Tech Plaza Mall',
  'Nyarugenge', 'Nyarugenge', 'Rugenge',
  '55555555-5555-5555-5555-555555555555',
  false,
  NULL,
  NOW() - INTERVAL '8 hours',
  NOW() - INTERVAL '8 hours'
);

-- Case 6: Suspicious Person (MEDIUM)
INSERT INTO reports (
  id, title, description, crime_type, status, priority, severity,
  latitude, longitude, address, district, sector, cell,
  user_id, is_anonymous, officer_id,
  created_at, updated_at
)
VALUES (
  '96666666-6666-6666-6666-666666666666',
  'Suspicious Person - School Area',
  'Individual reported loitering near elementary school playground during school hours. Has been seen multiple days. Parents express concerns about child safety.',
  'LOITERING',
  'PENDING',
  'MEDIUM',
  'LOW',
  -1.9558, 30.1012,
  'Sunrise Elementary School, 789 Education Road',
  'Gasabo', 'Kacyiru', 'Kamatamu',
  '11111111-1111-1111-1111-111111111111',
  false,
  NULL,
  NOW() - INTERVAL '1 day',
  NOW() - INTERVAL '1 day'
);

-- Case 7: Traffic Accident (LOW)
INSERT INTO reports (
  id, title, description, crime_type, status, priority, severity,
  latitude, longitude, address, district, sector, cell,
  user_id, is_anonymous, officer_id,
  created_at, updated_at
)
VALUES (
  '97777777-7777-7777-7777-777777777777',
  'Traffic Accident - Minor Collision',
  'Two-vehicle collision at intersection. No injuries. Both drivers exchanged information. Traffic cleared.',
  'TRAFFIC_ACCIDENT',
  'PENDING',
  'LOW',
  'LOW',
  -1.9553, 30.1007,
  'KN 4 Ave & KG 5 St Intersection',
  'Gasabo', 'Kimironko', 'Biryogo',
  '22222222-2222-2222-2222-222222222222',
  false,
  NULL,
  NOW() - INTERVAL '6 hours',
  NOW() - INTERVAL '6 hours'
);

-- Case 8: Noise Complaint (LOW)
INSERT INTO reports (
  id, title, description, crime_type, status, priority, severity,
  latitude, longitude, address, district, sector, cell,
  user_id, is_anonymous, officer_id,
  created_at, updated_at
)
VALUES (
  '98888888-8888-8888-8888-888888888888',
  'Noise Complaint - Residential',
  'Loud music and disturbance reported in residential area. Multiple complaints from neighbors. Party ongoing since 10 PM.',
  'NOISE_DISTURBANCE',
  'PENDING',
  'LOW',
  'LOW',
  -1.9545, 30.0998,
  'Nyarutarama Street, House 45',
  'Gasabo', 'Kacyiru', 'Kamatamu',
  '33333333-3333-3333-3333-333333333333',
  true,
  NULL,
  NOW() - INTERVAL '2 hours',
  NOW() - INTERVAL '2 hours'
);

-- =====================================================
-- Add some evidence files (optional)
-- =====================================================

-- Evidence for Case 1 (Bank Robbery)
INSERT INTO evidence_files (
  id, report_id, file_name, file_type, file_url, description,
  uploaded_by, created_at
)
VALUES (
  'e1111111-1111-1111-1111-111111111111',
  '91111111-1111-1111-1111-111111111111',
  'security-camera-1.mp4',
  'VIDEO',
  '/evidence/security-camera-1.mp4',
  'Bank security footage showing suspects entering',
  '11111111-1111-1111-1111-111111111111',
  NOW() - INTERVAL '1 hour'
);

-- Evidence for Case 4 (Vehicle Theft)
INSERT INTO evidence_files (
  id, report_id, file_name, file_type, file_url, description,
  uploaded_by, created_at
)
VALUES (
  'e4444444-4444-4444-4444-444444444444',
  '94444444-4444-4444-4444-444444444444',
  'home-security-cam.mp4',
  'VIDEO',
  '/evidence/home-security-cam.mp4',
  'Home security footage showing vehicle theft',
  '44444444-4444-4444-4444-444444444444',
  NOW() - INTERVAL '11 hours'
);

-- Evidence for Case 5 (Burglary)
INSERT INTO evidence_files (
  id, report_id, file_name, file_type, file_url, description,
  uploaded_by, created_at
)
VALUES (
  'e5555555-5555-5555-5555-555555555555',
  '95555555-5555-5555-5555-555555555555',
  'broken-window.jpg',
  'IMAGE',
  '/evidence/broken-window.jpg',
  'Photo of smashed storefront window',
  '55555555-5555-5555-5555-555555555555',
  NOW() - INTERVAL '7 hours'
);

-- =====================================================
-- Success message
-- =====================================================

SELECT '✅ Test data inserted successfully!' AS message;
SELECT 
  COUNT(*) AS total_reports,
  SUM(CASE WHEN status = 'PENDING' THEN 1 ELSE 0 END) AS pending_cases,
  SUM(CASE WHEN status = 'IN_PROGRESS' THEN 1 ELSE 0 END) AS active_cases,
  SUM(CASE WHEN priority = 'CRITICAL' OR priority = 'URGENT' THEN 1 ELSE 0 END) AS urgent_cases
FROM reports
WHERE id::text LIKE '9%';

SELECT '📋 View all test reports:' AS instruction;
SELECT id, title, status, priority, crime_type, created_at
FROM reports
WHERE id::text LIKE '9%'
ORDER BY priority DESC, created_at DESC;

