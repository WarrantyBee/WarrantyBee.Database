DELIMITER $$

DROP PROCEDURE IF EXISTS usp_UpdateVendorContact$$


CREATE PROCEDURE usp_UpdateVendorContact(
    in_vendor_id BIGINT,
    in_email VARCHAR(255),
    in_phone_number VARCHAR(32),
    in_phone_code VARCHAR(8)
)
proc_label:BEGIN
    DECLARE v_vendor_exists BOOLEAN DEFAULT FALSE;
    DECLARE v_contact_exists INT DEFAULT 0;

    -- Exit handler for any SQL exception
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @sql_error_message = MESSAGE_TEXT;
        SELECT 0 AS success, @sql_error_message AS message;
        ROLLBACK;
    END;

    -- Parameter validation
    
    IF in_vendor_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vendor ID must be provided.';
    END IF;

    -- Check if the vendor exists
    IF NOT ufn_DoesVendorExist(in_vendor_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vendor not found.';
    END IF;

    -- Check if contact exists and belongs to the vendor
    SELECT COUNT(1) INTO v_contact_exists FROM tblVendorContacts WHERE id = in_id AND vendor_id = in_vendor_id;
    IF v_contact_exists = 0 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Contact not found for this vendor.';
    END IF;

    IF in_email IS NOT NULL THEN 
        IF TRIM(in_email) = '' OR NOT in_email REGEXP '^[a-zA-Z0-9][a-zA-Z0-9._-]*@[a-zA-Z0-9][a-zA-Z0-9._-]*\\.[a-zA-Z]{2,10}$' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A valid email address is required.';
        ELSE
        UPDATE tblVendorContacts
        SET
        email = TRIM(in_email)
        WHERE id = in_vendor_id;
    END IF;


    IF in_phone_number IS NOT NULL THEN 
        IF TRIM(in_phone_number) = '' OR NOT in_phone_number REGEXP '^[0-9()\\-\\s+]+$' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A valid phone number is required.';
        ELSE
        UPDATE tblVendorContacts
        SET
        phone_number = TRIM(in_phone_number)
        WHERE id = in_vendor_id;
    END IF;
    
    IF in_phone_code IS NOT NULL THEN 
        IF TRIM(in_phone_code) = '' OR NOT in_phone_code REGEXP '^[0-9()\\-\\s+]+$' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A valid phone code is required.';
        ELSE
        UPDATE tblVendorContacts
        SET
        phone_code = TRIM(in_phone_code)
        WHERE id = in_vendor_id;
    END IF;

    SELECT 1 AS success, 'Contact updated successfully.' AS message;
END$$

DELIMITER ;