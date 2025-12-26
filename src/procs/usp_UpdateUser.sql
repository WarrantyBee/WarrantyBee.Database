
DELIMITER $$

DROP PROCEDURE IF EXISTS usp_UpdateUser$$

-- =============================================
-- usp_UpdateUser
-- Updates a user's basic information.
--
-- Parameters:
--   in_user_id       - The user's unique identifier.
--   in_firstname     - The user's first name.
--   in_lastname      - The user's last name.
--   in_email         - The user's email.
-- =============================================
CREATE PROCEDURE usp_UpdateUser(
    in_user_id BIGINT,
    in_firstname VARCHAR(128),
    in_lastname VARCHAR(128),
    in_email VARCHAR(255)
)
proc_label:BEGIN
    DECLARE v_user_exists BOOLEAN DEFAULT FALSE;

    -- Exit handler for any SQL exception
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @sql_error_message = MESSAGE_TEXT;
        SELECT 0 AS success, @sql_error_message AS message;
        ROLLBACK;
    END;

    -- Parameter validation
    IF in_user_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User ID must be provided.';
    END IF;

    -- Check if the user exists
    SELECT EXISTS(SELECT 1 FROM tblUsers WHERE id = in_user_id) INTO v_user_exists;
    IF NOT v_user_exists THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User not found.';
    END IF;

    -- Start transaction
    START TRANSACTION;

    -- Update user information
    UPDATE tblUsers
    SET
        firstname = IFNULL(in_firstname, firstname),
        lastname = IFNULL(in_lastname, lastname),
        email = IFNULL(in_email, email)
    WHERE id = in_user_id;

    -- Commit the transaction
    COMMIT;

    -- Return success message
    SELECT 1 AS success, 'User updated successfully.' AS message;

END$$

DELIMITER ;

SELECT 'usp_UpdateUser created successfully.' AS message;
