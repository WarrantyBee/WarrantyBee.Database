/*
================================================================================
--ufn_DoesPhoneCodeExist
-- Description: Checks if a phone code exists in the tblCountries table.
-- Parameters:
--   in_phone_code: The phone code to check.
-- Returns:
--   TRUE if the phone code exists, FALSE otherwise.
================================================================================
*/
DELIMITER $$

DROP FUNCTION IF EXISTS ufn_DoesPhoneCodeExist$$

CREATE FUNCTION ufn_DoesPhoneCodeExist(
    in_phone_code VARCHAR(8)
)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE v_phone_code_exists BOOLEAN DEFAULT FALSE;


    SELECT EXISTS(
        SELECT 1
        FROM tblCountries
        WHERE (in_phone_code IS NOT NULL AND phone_code = in_phone_code)
    )
    INTO v_phone_code_exists;

    RETURN v_phone_code_exists;
END$$

DELIMITER ;

SELECT 'ufn_DoesPhoneCodeExist created successfully.' AS message;
