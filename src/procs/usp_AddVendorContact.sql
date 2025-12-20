DELIMITER $$
DROP PROCEDURE IF EXISTS usp_AddVendorContact$$

CREATE PROCEDURE usp_AddVendorContact(
    IN in_vendor_id BIGINT UNSIGNED,
    IN in_type TINYINT,
    IN in_email VARCHAR(255),
    IN in_phone_number VARCHAR(32),
    IN in_country_id BIGINT UNSIGNED,
    IN in_culture_id BIGINT UNSIGNED,
    IN in_business_hours JSON
)
proc_label:BEGIN
    DECLARE v_vendor_contact_id BIGINT UNSIGNED;
    DECLARE v_record_exists INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        DECLARE v_error_message VARCHAR(255);
        GET DIAGNOSTICS CONDITION 1 v_error_message = MESSAGE_TEXT;
        ROLLBACK;
        SELECT NULL AS inserted_id, v_error_message AS message;
    END;

    IF in_vendor_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vendor ID is required.';
    END IF;

    IF in_type IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Contact type is required.';
    END IF;

    IF in_email IS NULL OR NOT in_email REGEXP '^[a-zA-Z0-9][a-zA-Z0-9._-]*@[a-zA-Z0-9][a-zA-Z0-9._-]*\\.[a-zA-Z]{2,4}$' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A valid email address is required.';
    END IF;



    IF in_country_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Country ID is required.';
    END IF;

    IF in_culture_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Culture ID is required.';
    END IF;

    IF in_business_hours IS NULL OR NOT JSON_VALID(in_business_hours) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Business hours are required and must be a valid JSON object.';
    END IF;
    
    SELECT COUNT(1) INTO v_record_exists FROM tblVendors WHERE id = in_vendor_id;
    IF v_record_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The specified vendor does not exist.';
    END IF;

    SELECT COUNT(1) INTO v_record_exists FROM tblCountries WHERE id = in_country_id;
    IF v_record_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_text = 'The specified country does not exist.';
    END IF;

    SELECT COUNT(1) INTO v_record_exists FROM tblCultures WHERE id = in_culture_id;
    IF v_record_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The specified culture does not exist.';
    END IF;
    
    SELECT COUNT(1) INTO v_record_exists FROM tblVendorContacts WHERE vendor_id = in_vendor_id AND email = in_email;
    IF v_record_exists > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This email address is already registered for this vendor.';
    END IF;

    START TRANSACTION;

    INSERT INTO tblVendorContacts (
        vendor_id,
        `type`,
        email,
        phone_number,
        country_id,
        culture_id,
        business_hours
    )
    VALUES (
        in_vendor_id,
        in_type,
        TRIM(in_email),
        in_phone_number,
        in_country_id,
        in_culture_id,
        TRIM(in_business_hours)
    );
    SET v_vendor_contact_id = LAST_INSERT_ID();

    COMMIT;

    SELECT v_vendor_contact_id AS inserted_id, 'Success' AS message;

END$$

DELIMITER ;

SELECT 'usp_AddVendorContact created successfully.' AS message;
