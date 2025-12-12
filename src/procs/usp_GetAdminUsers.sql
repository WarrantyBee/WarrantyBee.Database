DELIMITER $$
DROP PROCEDURE IF EXISTS usp_GetAdminUsers$$

CREATE PROCEDURE usp_GetAdminUsers(
    IN in_id BIGINT UNSIGNED,
    IN in_email VARCHAR(255)
)
proc_label:BEGIN
    DECLARE v_user_exists INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        DECLARE v_error_message VARCHAR(255);
        GET DIAGNOSTICS CONDITION 1 v_error_message = MESSAGE_TEXT;
        SELECT 1 AS status, v_error_message AS message;
    END;

    IF in_id IS NULL AND (in_email IS NULL OR TRIM(in_email) = '') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Either an admin user ID or an email must be provided.';
    END IF;

    SELECT COUNT(1) INTO v_user_exists
    FROM tblAdminUsers
    WHERE (in_id IS NOT NULL AND id = in_id) OR (in_email IS NOT NULL AND email = in_email);

    IF v_user_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Admin user not found.';
    END IF;

    SELECT 0 AS status, 'Success' AS message;

    SELECT
        id,
        BIN_TO_UUID(internal_id) AS internal_id,
        firstname,
        lastname,
        email,
        created_at,
        updated_at,
        mfa_enabled,
        `password`,
        permissions
    FROM
        tblAdminUsers
    WHERE (in_id IS NOT NULL AND id = in_id)
    OR (in_email IS NOT NULL AND email = in_email)
    LIMIT 1;

END$$

DELIMITER ;

SELECT 'usp_GetAdminUsers created successfully.' AS message;