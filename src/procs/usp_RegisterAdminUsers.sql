DELIMITER $$

DROP PROCEDURE IF EXISTS usp_GetRegisterAdminUsers$$

CREATE PROCEDURE usp_GetRegisterAdminUsers(
    IN in_firstname VARCHAR(128),  
    IN in_lastname VARCHAR(128),
    IN in_email VARCHAR(255),
    IN in_password VARCHAR(1024),
    IN in_permissions VARCHAR(1024)
)
proc_label:BEGIN
    
    DECLARE v_record_exists INT DEFAULT 0;
    DECLARE v_permissions_json VARCHAR(1200);
    DECLARE v_allowed_permissions VARCHAR(1024);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        DECLARE v_error_message VARCHAR(255);
        GET DIAGNOSTICS CONDITION 1 v_error_message = MESSAGE_TEXT;
        SELECT 1 AS status, v_error_message AS message;
    END;

    IF in_firstname IS NULL OR TRIM(in_firstname) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'First name is required.';
    END IF;
    
    IF in_lastname IS NULL OR TRIM(in_lastname) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Last name is required.';
    END IF;

    IF in_email IS NULL OR NOT in_email REGEXP '^[a-zA-Z0-9][a-zA-Z0-9._-]*@[a-zA-Z0-9][a-zA-Z0-9._-]*\\.[a-zA-Z]{2,4}$' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A valid email address is required.';
    END IF;

    IF in_password IS NULL OR TRIM(in_password) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Password is required.';
    END IF;

    IF in_permissions IS NULL OR TRIM(in_permissions) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'At least one permission is required.';
    END IF;

    SELECT COUNT(1) INTO v_record_exists FROM tblAdminUsers WHERE email = in_email;
    IF v_record_exists > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This email address is already registered.';
    END IF;

    SET v_permissions_json = CONCAT('["', REPLACE(in_permissions, ',', '","'), '"]');

    CREATE TEMPORARY TABLE tmpTblPermissions AS 
    SELECT TRIM(value) AS permission
    FROM JSON_TABLE(
        v_permissions_json, 
        '$[*]' COLUMNS (value VARCHAR(255) PATH '$') 
    );

    SELECT GROUP_CONCAT(tp.permission) 
    INTO v_allowed_permissions
    FROM tmpTblPermissions AS ttp
    LEFT JOIN tblPermissions AS tp 
    ON ttp.permission = tp.name 
    WHERE tp.name IS NOT NULL;

    DROP TEMPORARY TABLE IF EXISTS tmpTblPermissions;

    IF v_allowed_permissions IS NULL OR TRIM(v_allowed_permissions) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'At least one valid permission is required.';
    END IF;


    INSERT INTO tblUsers (
        firstname,
        lastname,
        email,
        `password`,
        permissions
    )
    VALUES (
        TRIM(in_firstname),
        TRIM(in_lastname),
        TRIM(in_email),
        in_password,
        v_allowed_permissions
    );

    SET v_user_id = LAST_INSERT_ID();
    SELECT v_user_id AS inserted_id, 'Success' AS message;

END$$

DELIMITER ;

SELECT 'usp_RegisterAdminUsers created successfully.' AS message;