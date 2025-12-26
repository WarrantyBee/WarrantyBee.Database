
DELIMITER $$

DROP PROCEDURE IF EXISTS usp_ChangePassword$$

-- =============================================
-- usp_ChangePassword
-- Changes a user's password after verifying the old password.
--
-- Parameters:
--   in_user_id       - The user's unique identifier.
--   in_old_password  - The user's current password.
--   in_new_password  - The new password to set.
-- =============================================
CREATE PROCEDURE usp_ChangePassword(
    in_user_id BIGINT,
    in_old_password VARCHAR(1024),
    in_new_password VARCHAR(1024)
)
proc_label:BEGIN
    DECLARE v_current_password VARCHAR(1024);
    DECLARE v_user_exists BOOLEAN DEFAULT FALSE;

    -- Exit handler for any SQL exception
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @sql_error_message = MESSAGE_TEXT;
        SELECT 1 AS status, @sql_error_message AS message;
        ROLLBACK;
    END;

    -- Parameter validation
    IF in_user_id IS NULL OR in_old_password IS NULL OR in_new_password IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'All parameters must be provided.';
    END IF;

    -- Check if the user exists
    SELECT EXISTS(SELECT 1 FROM tblUsers WHERE id = in_user_id) INTO v_user_exists;
    IF NOT v_user_exists THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User not found.';
    END IF;

    -- Retrieve the current password
    SELECT `password` INTO v_current_password FROM tblUsers WHERE id = in_user_id;

    -- Verify the old password
    IF v_current_password != in_old_password THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Incorrect old password.';
    END IF;

    -- Check if the new password is the same as the old one
    IF in_new_password = in_old_password THEN
        SELECT -1 AS status, 'New password cannot be the same as the old password.' AS message;
        LEAVE proc_label;
    END IF;

    -- Start transaction
    START TRANSACTION;

    -- Update the password
    UPDATE tblUsers SET `password` = in_new_password, password_updated_at = UTC_TIMESTAMP() WHERE id = in_user_id;

    -- Log the old password
    INSERT INTO tblPasswordLogs (user_id, `password`) VALUES (in_user_id, v_current_password);

    -- Commit the transaction
    COMMIT;

    -- Return success message
    SELECT 0 AS status, 'Password changed successfully.' AS message;

END$$

DELIMITER ;

SELECT 'usp_ChangePassword created successfully.' AS message;
