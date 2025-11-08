DELIMITER $$

DROP FUNCTION IF EXISTS ufn_ValidateLoginToken$$

-- =============================================
-- ufn_ValidateLoginToken
-- Validates the login token for a user.
--
-- Parameters:
--   in_user_id   - The user's identifier.
--   in_token     - The login token to validate.
--
-- Returns:
--   TRUE if the token is valid, FALSE otherwise.
-- =============================================
CREATE FUNCTION ufn_ValidateLoginToken(
    in_user_id BIGINT,
    in_token VARCHAR(255)
)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE v_stored_token VARCHAR(255);

    IF in_user_id IS NULL OR in_token IS NULL OR TRIM(in_token) = '' THEN
        RETURN FALSE;
    END IF;

    SELECT login_token INTO v_stored_token
    FROM tblUsers
    WHERE id = in_user_id;

    UPDATE tblUsers
    SET login_token = NULL
    WHERE id = in_user_id;

    IF v_stored_token IS NOT NULL AND v_stored_token = in_token THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END$$

DELIMITER ;
SELECT 'ufn_ValidateLoginToken created successfully.' AS message;