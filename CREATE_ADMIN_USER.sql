-- SQL Script to Create Admin User
-- Run this in H2 Console: http://localhost:8080/h2-console

-- 1. First, check if admin exists
SELECT * FROM users WHERE role = 'ADMIN';

-- 2. Create admin user
-- Password: admin123 (BCrypt hash)
INSERT INTO users (id, username, mobile, password, full_name, role, enabled, created_at, updated_at, is_verified, verification_status)
VALUES (
    999,
    'admin',
    '9999999999',
    '$2a$10$slYQmyNdGzTn7ZLBXBChFOC9f6kFjAqPhccnP6DxlWXx2lPk1C3G6',
    'System Administrator',
    'ADMIN',
    true,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    true,
    'APPROVED'
);

-- 3. Verify admin was created
SELECT * FROM users WHERE role = 'ADMIN';

-- Alternative: Update existing user to admin
-- UPDATE users SET role = 'ADMIN' WHERE mobile = 'YOUR_MOBILE_NUMBER';
