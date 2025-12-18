DELIMITER $$

DROP PROCEDURE IF EXISTS usp_RegisterVendors$$

CREATE PROCEDURE usp_RegisterVendors(
    IN in_user_id BIGINT UNSIGNED,
    IN in_name VARCHAR(128),
    IN in_legal_name VARCHAR(255),
    IN in_vendor_code VARCHAR(100),
    IN in_vendor_type VARCHAR(32),
    IN in_primary_email VARCHAR(255),
    IN in_primary_phone VARCHAR(32),
    IN in_website VARCHAR(255),
    IN in_support_email VARCHAR(255),
    IN in_business_registration_number VARCHAR(64),
    IN in_business_registration_type BIGINT UNSIGNED,
    IN in_tax_identifier VARCHAR(64),
    IN in_tax_country_id BIGINT UNSIGNED,
    IN in_status VARCHAR(16)
)
proc_label:BEGIN
    DECLARE v_vendor_id BIGINT UNSIGNED;
    DECLARE v_record_exists INT DEFAULT 0;
    DECLARE v_verified BOOLEAN DEFAULT FALSE;
    DECLARE v_void BOOLEAN DEFAULT FALSE;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        DECLARE v_error_message VARCHAR(255);
        GET DIAGNOSTICS CONDITION 1 v_error_message = MESSAGE_TEXT;
        ROLLBACK;
        SELECT NULL AS inserted_id, v_error_message AS message;
    END;

    IF in_user_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User ID is required.';
    END IF;

    IF in_name IS NULL OR TRIM(in_name) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Name is required.';
    END IF;

    IF in_vendor_code IS NULL OR TRIM(in_vendor_code) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vendor code is required.';
    END IF;

    IF in_vendor_type IS NULL OR TRIM(in_vendor_type) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vendor type is required.';
    END IF;

    IF in_primary_email IS NULL OR NOT in_primary_email REGEXP '^[a-zA-Z0-9][a-zA-Z0-9._-]*@[a-zA-Z0-9][a-zA-Z0-9._-]*\\.[a-zA-Z]{2,4}$' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A valid primary email address is required.';
    END IF;

    IF in_primary_phone IS NULL OR TRIM(in_primary_phone) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Primary phone number is required.';
    END IF;
    
    IF in_status IS NULL OR TRIM(in_status) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Status is required.';
    END IF;

    SELECT COUNT(1) INTO v_record_exists FROM tblUsers WHERE id = in_user_id;
    IF v_record_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The specified user does not exist.';
    END IF;

    SELECT COUNT(1) INTO v_record_exists FROM tblVendors WHERE primary_email = in_primary_email;
    IF v_record_exists > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This email address is already registered.';
    END IF;

    SELECT COUNT(1) INTO v_record_exists FROM tblVendors WHERE vendor_code = in_vendor_code;
    IF v_record_exists > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This vendor code is already registered.';
    END IF;

    IF in_tax_country_id IS NOT NULL THEN
        SELECT COUNT(1) INTO v_record_exists FROM tblCountries WHERE id = in_tax_country_id;
        IF v_record_exists = 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The specified tax country does not exist.';
        END IF;
    END IF;

    START TRANSACTION;

    INSERT INTO tblVendors (
        name,
        legal_name,
        vendor_code,
        vendor_type,
        primary_email,
        primary_phone,
        website,
        support_email,
        business_registration_number,
        business_registration_type,
        tax_identifier,
        tax_country_id,
        status,
        verified,
        void
    )
    VALUES (
        TRIM(in_name),
        TRIM(in_legal_name),
        TRIM(in_vendor_code),
        TRIM(in_vendor_type),
        TRIM(in_primary_email),
        TRIM(in_primary_phone),
        TRIM(in_website),
        TRIM(in_support_email),
        TRIM(in_business_registration_number),
        in_business_registration_type,
        TRIM(in_tax_identifier),
        in_tax_country_id,
        TRIM(in_status),
        v_verified,
        v_void
    );
    SET v_vendor_id = LAST_INSERT_ID();

    INSERT INTO tblVendorLogins (vendor_id, user_id)
    VALUES (v_vendor_id, in_user_id);

    COMMIT;

    SELECT v_vendor_id AS inserted_id, 'Success' AS message;

END$$

DELIMITER ;

SELECT 'usp_RegisterVendors created successfully.' AS message;