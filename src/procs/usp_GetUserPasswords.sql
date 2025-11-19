DELIMITER $$

DROP PROCEDURE IF EXISTS usp_GetUserPasswords$$

-- =============================================
-- usp_GetUserPasswords
-- Retrieves the current password from tblUsers and all old passwords from tblPasswordLogs for a given user.
--
-- Parameters:
--   in_user_id - The identifier of the user.
-- =============================================
CREATE PROCEDURE usp_GetUserPasswords(
    IN in_user_id BIGINT UNSIGNED
)
proc_label:BEGIN
    IF in_user_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User ID is required.';
    END IF;

    SELECT `password` FROM tblUsers WHERE id = in_user_id
    UNION ALL
    SELECT `password` FROM tblPasswordLogs WHERE user_id = in_user_id;
END$$

DELIMITER ;

SELECT 'usp_GetUserPasswords created successfully.' AS message;