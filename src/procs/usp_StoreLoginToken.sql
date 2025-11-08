DELIMITER $$

DROP PROCEDURE IF EXISTS usp_StoreLoginToken$$

-- =============================================
-- usp_StoreLoginToken
-- Stores the login token for a user.
--
-- Parameters:
--   in_user_id   - The user's identifier.
--   in_token     - The login token to store.
-- =============================================
CREATE PROCEDURE usp_StoreLoginToken(
    in_user_id INT,
    in_token VARCHAR(255)
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

    IF in_token IS NULL OR TRIM(in_token) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Token must be provided.';
    END IF;

    UPDATE tblUsers
    SET login_token = in_token
    WHERE id = in_user_id;

    SELECT 0 AS status, 'Success' AS message;
END$$

DELIMITER ;
SELECT 'usp_StoreLoginToken created successfully.' AS message;