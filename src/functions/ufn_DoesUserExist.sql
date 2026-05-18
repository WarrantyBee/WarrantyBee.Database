DROP FUNCTION IF EXISTS ufn_DoesUserExist;
DELIMITER $$

-- =============================================
-- ufn_DoesUserExist
-- Checks if a user exists in the tblUsers table based on the user ID or email address.
--
-- Parameters:
--   in_id - The ID of the user to check.
--   in_email - The email address of the user to check.
--
-- Returns:
--   BOOLEAN - TRUE if the user exists, FALSE otherwise.
--
-- Usage:
--   SELECT ufn_DoesUserExist(1, NULL);
--   SELECT ufn_DoesUserExist(NULL, 'test@example.com');
-- =============================================
CREATE FUNCTION ufn_DoesUserExist(
    in_id BIGINT UNSIGNED,
    in_email VARCHAR(255)
)
RETURNS BOOLEAN
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_user_exists BOOLEAN;

    SELECT EXISTS(
        SELECT 1
        FROM tblUsers
        WHERE
            (in_id IS NOT NULL AND id = in_id) OR
            (in_email IS NOT NULL AND email = in_email)
    ) INTO v_user_exists;

    RETURN v_user_exists;
END$$

DELIMITER ;
