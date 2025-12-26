/*
================================================================================
--ufn_DoesVendorExist
-- Description: Checks if a vendor exists in the tblVendors table by ID or email.
-- Parameters:
--   in_id:    The ID of the vendor to check.
--   in_email: The email of the vendor to check.
-- Returns:
--   TRUE if a vendor with the specified ID or email exists, FALSE otherwise.
================================================================================
*/
DELIMITER $$

DROP FUNCTION IF EXISTS ufn_DoesVendorExist$$

CREATE FUNCTION ufn_DoesVendorExist(
    in_id BIGINT UNSIGNED,
    in_email VARCHAR(255)
)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE v_vendor_exists BOOLEAN DEFAULT FALSE;

    SELECT EXISTS(
        SELECT 1
        FROM tblVendors
        WHERE (in_id IS NOT NULL AND id = in_id)
        OR (in_email IS NOT NULL AND email = in_email)
    )
    INTO v_vendor_exists;

    RETURN v_vendor_exists;
END$$

DELIMITER ;

SELECT 'ufn_DoesVendorExist created successfully.' AS message;
