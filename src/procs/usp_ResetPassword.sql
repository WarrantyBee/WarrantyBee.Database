
DELIMITER $$

DROP PROCEDURE IF EXISTS usp_ResetPassword$$

-- =============================================
-- usp_ResetPassword
-- Resets the password for a user.
--
-- Parameters:
--   in_user_id       - The user's identifier.
--   in_new_password  - The new password to set.
-- =============================================
CREATE PROCEDURE usp_ResetPassword(
    in_user_id INT,
    in_new_password VARCHAR(255)
)
proc_label:BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        DECLARE v_error_message VARCHAR(255);
        GET DIAGNOSTICS CONDITION 1 v_error_message = MESSAGE_TEXT;
        SELECT 1 AS status, v_error_message AS message;
    END;

    IF in_user_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User identifier must be provided.';
    END IF;

    IF in_new_password IS NULL OR TRIM(in_new_password) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'New password must be provided.';
    END IF;

    UPDATE tblUsers
    SET `password` = in_new_password
    WHERE id = in_user_id;

    SELECT 0 AS status, 'Success' AS message;
END$$

DELIMITER ;
SELECT 'usp_ResetPassword created successfully.' AS message;
