DELIMITER $$
DROP FUNCTION IF EXISTS ufn_ValidateOtp$$

-- =============================================
-- ufn_ValidateOtp
-- Checks if an OTP is valid for a given recipient.
--
-- Parameters:
--   in_recipient - The recipient's email address.
--   in_value  - The OTP value to validate.
--
-- Returns:
--   TRUE if the OTP is valid, otherwise FALSE.
-- =============================================

CREATE FUNCTION ufn_ValidateOtp(
    in_recipient VARCHAR(255),
    in_value VARCHAR(255)
)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE v_is_valid BOOLEAN DEFAULT FALSE;
    DECLARE v_active BOOLEAN DEFAULT FALSE;
    DECLARE v_created_at TIMESTAMP;

    SELECT
        created_at INTO v_created_at
    FROM
        tblOtp
    WHERE
        recipient = in_recipient AND value = in_value AND void = v_active
    ORDER BY
        created_at DESC
    LIMIT 1;

    IF v_created_at IS NOT NULL THEN
        IF v_created_at >= DATE_SUB(UTC_TIMESTAMP(), INTERVAL 1 MINUTE) THEN
            SET v_is_valid = TRUE;
        END IF;
    END IF;

    RETURN v_is_valid;
END$$

DELIMITER ;
SELECT 'ufn_ValidateOtp created successfully.' AS message;