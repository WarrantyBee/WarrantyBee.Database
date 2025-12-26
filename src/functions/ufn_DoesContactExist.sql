/*
================================================================================
--ufn_DoesContactExist
-- Description: Checks if a vendor contact exists based on email or phone number.
-- Parameters:
--   in_email:      The email address to check.
--   in_phone_number: The phone number to check.
-- Returns:
--   TRUE if a contact with the specified email or phone number exists, FALSE otherwise.
================================================================================
*/
DELIMITER $$

DROP FUNCTION IF EXISTS ufn_DoesContactExist$$


CREATE FUNCTION ufn_DoesContactExist(
    in_email VARCHAR(255),
    in_phone_number VARCHAR(32)
)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE v_contact_exists BOOLEAN DEFAULT FALSE;


    SELECT EXISTS(
        SELECT 1
        FROM tblVendorContacts
        WHERE (in_email IS NOT NULL AND email = in_email)
           OR (in_phone_number IS NOT NULL AND phone_number = in_phone_number)
    )
    INTO v_contact_exists;

    RETURN v_contact_exists;
END$$

DELIMITER ;

SELECT 'ufn_DoesContactExist created successfully.' AS message;
