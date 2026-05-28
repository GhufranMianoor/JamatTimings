-- ============================================================
-- Jamat Timing App — Seed Data
-- ============================================================
-- Development seed: 1 super admin + 5 sample masjids in Lahore

-- ============================================================
-- Super Admin User
-- ============================================================
-- Note: The auth_uid will be linked after the user is created in
-- Supabase Auth. Create a user in the Auth dashboard first with
-- the email below, then update auth_uid here.

INSERT INTO admin_user (id, email, full_name, role, is_active)
VALUES (
    'a0000000-0000-0000-0000-000000000001',
    'admin@jamattimings.pk',
    'System Administrator',
    'super_admin',
    TRUE
);

-- ============================================================
-- Sample Masjid Admin
-- ============================================================

INSERT INTO admin_user (id, email, full_name, role, is_active)
VALUES (
    'a0000000-0000-0000-0000-000000000002',
    'imam.badshahi@example.com',
    'Muhammad Ahmad',
    'masjid_admin',
    TRUE
);

-- ============================================================
-- Sample Masjids (Lahore, Pakistan)
-- ============================================================

INSERT INTO masjid (id, name, address, city, area, latitude, longitude, contact_phone, imam_name, status) VALUES
(
    'm0000000-0000-0000-0000-000000000001',
    'Badshahi Masjid',
    'Walled City of Lahore, Fort Road',
    'Lahore',
    'Walled City',
    31.5882, 74.3106,
    '+92-42-99214554',
    'Maulana Abdul Khabeer Azad',
    'active'
),
(
    'm0000000-0000-0000-0000-000000000002',
    'Masjid Wazir Khan',
    'Shahi Guzargah, Walled City',
    'Lahore',
    'Walled City',
    31.5836, 74.3173,
    NULL,
    NULL,
    'active'
),
(
    'm0000000-0000-0000-0000-000000000003',
    'Jamia Masjid Al-Rehman',
    'Main Boulevard, Gulberg III',
    'Lahore',
    'Gulberg',
    31.5204, 74.3587,
    '+92-42-35761234',
    'Maulana Tariq Jameel',
    'active'
),
(
    'm0000000-0000-0000-0000-000000000004',
    'Masjid-e-Shuhada',
    'Mall Road, near Shimla Hill',
    'Lahore',
    'Mall Road',
    31.5574, 74.3340,
    '+92-42-36304567',
    NULL,
    'active'
),
(
    'm0000000-0000-0000-0000-000000000005',
    'Jamia Masjid Defence',
    'Phase 5, DHA',
    'Lahore',
    'DHA',
    31.4677, 74.3760,
    '+92-42-35721111',
    'Mufti Muhammad Naeem',
    'active'
);

-- ============================================================
-- Assign sample admin to Badshahi Masjid
-- ============================================================

INSERT INTO admin_masjid (admin_id, masjid_id)
VALUES (
    'a0000000-0000-0000-0000-000000000002',
    'm0000000-0000-0000-0000-000000000001'
);

-- ============================================================
-- Sample Prayer Timings (for all 5 masjids)
-- ============================================================

-- Badshahi Masjid
INSERT INTO prayer_timing (masjid_id, prayer, jamat_time, label, updated_by) VALUES
('m0000000-0000-0000-0000-000000000001', 'fajr',    '05:00', '1st Jamat', 'a0000000-0000-0000-0000-000000000002'),
('m0000000-0000-0000-0000-000000000001', 'fajr',    '05:30', '2nd Jamat', 'a0000000-0000-0000-0000-000000000002'),
('m0000000-0000-0000-0000-000000000001', 'dhuhr',   '13:15', NULL,         'a0000000-0000-0000-0000-000000000002'),
('m0000000-0000-0000-0000-000000000001', 'asr',     '17:00', NULL,         'a0000000-0000-0000-0000-000000000002'),
('m0000000-0000-0000-0000-000000000001', 'maghrib', '19:15', NULL,         'a0000000-0000-0000-0000-000000000002'),
('m0000000-0000-0000-0000-000000000001', 'isha',    '20:45', NULL,         'a0000000-0000-0000-0000-000000000002'),
('m0000000-0000-0000-0000-000000000001', 'jumuah',  '13:00', 'Khutbah',    'a0000000-0000-0000-0000-000000000002'),
('m0000000-0000-0000-0000-000000000001', 'jumuah',  '13:30', 'Jamat',      'a0000000-0000-0000-0000-000000000002');

-- Masjid Wazir Khan
INSERT INTO prayer_timing (masjid_id, prayer, jamat_time, label) VALUES
('m0000000-0000-0000-0000-000000000002', 'fajr',    '05:15', NULL),
('m0000000-0000-0000-0000-000000000002', 'dhuhr',   '13:30', NULL),
('m0000000-0000-0000-0000-000000000002', 'asr',     '17:15', NULL),
('m0000000-0000-0000-0000-000000000002', 'maghrib', '19:15', NULL),
('m0000000-0000-0000-0000-000000000002', 'isha',    '21:00', NULL);

-- Jamia Masjid Al-Rehman
INSERT INTO prayer_timing (masjid_id, prayer, jamat_time, label) VALUES
('m0000000-0000-0000-0000-000000000003', 'fajr',    '04:45', NULL),
('m0000000-0000-0000-0000-000000000003', 'dhuhr',   '13:00', NULL),
('m0000000-0000-0000-0000-000000000003', 'asr',     '16:45', NULL),
('m0000000-0000-0000-0000-000000000003', 'maghrib', '19:10', NULL),
('m0000000-0000-0000-0000-000000000003', 'isha',    '20:30', NULL);

-- Masjid-e-Shuhada
INSERT INTO prayer_timing (masjid_id, prayer, jamat_time, label) VALUES
('m0000000-0000-0000-0000-000000000004', 'fajr',    '05:00', NULL),
('m0000000-0000-0000-0000-000000000004', 'dhuhr',   '13:15', NULL),
('m0000000-0000-0000-0000-000000000004', 'asr',     '17:00', NULL),
('m0000000-0000-0000-0000-000000000004', 'maghrib', '19:20', NULL),
('m0000000-0000-0000-0000-000000000004', 'isha',    '20:45', NULL);

-- Jamia Masjid Defence
INSERT INTO prayer_timing (masjid_id, prayer, jamat_time, label) VALUES
('m0000000-0000-0000-0000-000000000005', 'fajr',    '05:10', NULL),
('m0000000-0000-0000-0000-000000000005', 'dhuhr',   '13:30', NULL),
('m0000000-0000-0000-0000-000000000005', 'asr',     '17:15', NULL),
('m0000000-0000-0000-0000-000000000005', 'maghrib', '19:15', NULL),
('m0000000-0000-0000-0000-000000000005', 'isha',    '21:00', NULL),
('m0000000-0000-0000-0000-000000000005', 'jumuah',  '12:45', 'Khutbah'),
('m0000000-0000-0000-0000-000000000005', 'jumuah',  '13:15', 'Jamat');
