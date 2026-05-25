-- 1. Create Philips Business Profile
IF NOT EXISTS (SELECT 1 FROM tblBusinessProfiles WHERE name = 'Philips')
BEGIN
    INSERT INTO tblBusinessProfiles (internal_id, name, legal_name, tax_id, website, logo_url, support_email, is_verified, owner_user_id, created_at, void)
    VALUES (NEWID(), 'Philips', 'Philips India Pvt Ltd', 'TAX123456', 'https://philips.com', NULL, 'support@philips.com', 1, 0, GETUTCDATE(), 0);
END
GO

DECLARE @business_id BIGINT = (SELECT id FROM tblBusinessProfiles WHERE name = 'Philips');
DECLARE @password_hash VARCHAR(1024) = '$argon2id$v=19$m=65536,t=3,p=1$c2FsdHNhbHRzYWx0c2FsdA==$zT/3+xl3I3Cqq5G8EuhrOzswoyIZ3sPVkuyany6B5Q4=';

-- 2. Create Platform Admin
IF NOT EXISTS (SELECT 1 FROM tblUsers WHERE email = 'admin@warrantybee.com')
BEGIN
    INSERT INTO tblUsers (internal_id, email, password, role_id, firstname, lastname, accepted_tnc, accepted_pp, auth_provider, business_id, created_at, void)
    VALUES (NEWID(), 'admin@warrantybee.com', @password_hash, 1, 'Platform', 'Admin', 1, 1, 1, NULL, GETUTCDATE(), 0);
END
ELSE
BEGIN
    UPDATE tblUsers SET password = @password_hash WHERE email = 'admin@warrantybee.com';
END

DECLARE @admin_id BIGINT = (SELECT id FROM tblUsers WHERE email = 'admin@warrantybee.com');
IF NOT EXISTS (SELECT 1 FROM tblUserProfiles WHERE user_id = @admin_id)
BEGIN
    INSERT INTO tblUserProfiles (internal_id, user_id, phone_code, phone_number, gender, date_of_birth, address_line1, region_id, country_id, city, postal_code, culture_id, created_at, void)
    VALUES (NEWID(), @admin_id, '+91', '9999999999', 1, '1990-01-01', 'Admin Street', 29, 1, 'Admin City', '123456', 1, GETUTCDATE(), 0);
END

-- 3. Create Business Owner
IF NOT EXISTS (SELECT 1 FROM tblUsers WHERE email = 'owner@philips.com')
BEGIN
    INSERT INTO tblUsers (internal_id, email, password, role_id, firstname, lastname, accepted_tnc, accepted_pp, auth_provider, business_id, created_at, void)
    VALUES (NEWID(), 'owner@philips.com', @password_hash, 3, 'Philips', 'Owner', 1, 1, 1, @business_id, GETUTCDATE(), 0);
END
ELSE
BEGIN
    UPDATE tblUsers SET password = @password_hash WHERE email = 'owner@philips.com';
END

DECLARE @owner_id BIGINT = (SELECT id FROM tblUsers WHERE email = 'owner@philips.com');
IF NOT EXISTS (SELECT 1 FROM tblUserProfiles WHERE user_id = @owner_id)
BEGIN
    INSERT INTO tblUserProfiles (internal_id, user_id, phone_code, phone_number, gender, date_of_birth, address_line1, region_id, country_id, city, postal_code, culture_id, created_at, void)
    VALUES (NEWID(), @owner_id, '+91', '8888888888', 1, '1985-05-05', 'Owner Street', 29, 1, 'Owner City', '123456', 1, GETUTCDATE(), 0);
END

-- 4. Create Brand Support
IF NOT EXISTS (SELECT 1 FROM tblUsers WHERE email = 'support@philips.com')
BEGIN
    INSERT INTO tblUsers (internal_id, email, password, role_id, firstname, lastname, accepted_tnc, accepted_pp, auth_provider, business_id, created_at, void)
    VALUES (NEWID(), 'support@philips.com', @password_hash, 6, 'Philips', 'Support', 1, 1, 1, @business_id, GETUTCDATE(), 0);
END
ELSE
BEGIN
    UPDATE tblUsers SET password = @password_hash WHERE email = 'support@philips.com';
END

DECLARE @support_id BIGINT = (SELECT id FROM tblUsers WHERE email = 'support@philips.com');
IF NOT EXISTS (SELECT 1 FROM tblUserProfiles WHERE user_id = @support_id)
BEGIN
    INSERT INTO tblUserProfiles (internal_id, user_id, phone_code, phone_number, gender, date_of_birth, address_line1, region_id, country_id, city, postal_code, culture_id, created_at, void)
    VALUES (NEWID(), @support_id, '+91', '7777777777', 2, '1995-10-10', 'Support Street', 29, 1, 'Support City', '123456', 1, GETUTCDATE(), 0);
END

-- 5. Create Customer
IF NOT EXISTS (SELECT 1 FROM tblUsers WHERE email = 'customer@gmail.com')
BEGIN
    INSERT INTO tblUsers (internal_id, email, password, role_id, firstname, lastname, accepted_tnc, accepted_pp, auth_provider, business_id, created_at, void)
    VALUES (NEWID(), 'customer@gmail.com', @password_hash, 11, 'John', 'Doe', 1, 1, 1, NULL, GETUTCDATE(), 0);
END
ELSE
BEGIN
    UPDATE tblUsers SET password = @password_hash WHERE email = 'customer@gmail.com';
END

DECLARE @customer_id BIGINT = (SELECT id FROM tblUsers WHERE email = 'customer@gmail.com');
IF NOT EXISTS (SELECT 1 FROM tblUserProfiles WHERE user_id = @customer_id)
BEGIN
    INSERT INTO tblUserProfiles (internal_id, user_id, phone_code, phone_number, gender, date_of_birth, address_line1, region_id, country_id, city, postal_code, culture_id, created_at, void)
    VALUES (NEWID(), @customer_id, '+91', '6666666666', 1, '2000-07-02', 'Customer Street', 29, 1, 'Customer City', '123456', 1, GETUTCDATE(), 0);
END

-- Update all other logins to Soham@2020 as requested
UPDATE tblUsers SET password = @password_hash WHERE password <> @password_hash;
GO

-- Update business profile owner ID
UPDATE b
SET b.owner_user_id = u.id
FROM tblBusinessProfiles b
JOIN tblUsers u ON u.email = 'owner@philips.com'
WHERE b.name = 'Philips' AND b.owner_user_id = 0;
GO

-- Add a demo product for Philips
DECLARE @philips_id BIGINT = (SELECT id FROM tblBusinessProfiles WHERE name = 'Philips');
IF NOT EXISTS (SELECT 1 FROM tblProducts WHERE sku = 'PHILIPS-HD9200')
BEGIN
    INSERT INTO tblProducts (internal_id, business_id, sku, name, category, image_url, default_warranty_months, created_at, void)
    VALUES (NEWID(), @philips_id, 'PHILIPS-HD9200', 'Philips Air Fryer HD9200', 'Kitchen Appliances', 'https://m.media-amazon.com/images/I/61S3+3W2W3L._SL1500_.jpg', 24, GETUTCDATE(), 0);
END
GO
