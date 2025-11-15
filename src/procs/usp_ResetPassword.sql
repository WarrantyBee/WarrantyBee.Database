
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
    DECLARE v_old_password VARCHAR(255);
    DECLARE v_password_updated_at TIMESTAMP;
    DECLARE v_user_found BOOLEAN DEFAULT FALSE;
    DECLARE v_error_message VARCHAR(255);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 v_error_message = MESSAGE_TEXT;
        SELECT 1 AS status, v_error_message AS message;
        ROLLBACK;
    END;

    IF in_user_id IS NULL THEN
        SET v_error_message = 'User identifier must be provided.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_error_message;
    END IF;

    IF in_new_password IS NULL OR TRIM(in_new_password) = '' THEN
        SET v_error_message = 'New password must be provided.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_error_message;
    END IF;

    SELECT EXISTS (
        SELECT 1
        FROM tblUsers
        WHERE id = in_user_id
    ) INTO v_user_found;

    IF NOT v_user_found THEN
        SET v_error_message = 'User not found.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_error_message;
    END IF;

    SELECT password_updated_at INTO v_password_updated_at
    FROM tblUsers
    WHERE id = in_user_id;

    IF v_password_updated_at IS NOT NULL AND
    UTC_TIMESTAMP() BETWEEN v_password_updated_at AND
    v_password_updated_at + INTERVAL 10 MINUTE THEN
        SELECT -1 AS status, 'Password was recently updated. Please wait before resetting again.' AS message;
        LEAVE proc_label;
    ELSE
        START TRANSACTION;

        SELECT `password` INTO v_old_password
        FROM tblUsers
        WHERE id = in_user_id;

        UPDATE tblUsers
        SET `password` = in_new_password,
        password_updated_at = UTC_TIMESTAMP()
        WHERE id = in_user_id;

        INSERT INTO tblPasswordLogs (`user_id`, `password`)
        VALUES (in_user_id, v_old_password);

        COMMIT;
        
        SELECT 0 AS status, 'Success' AS message;
    END IF;
END$$

DELIMITER ;
SELECT 'usp_ResetPassword created successfully.' AS message;
