DELIMITER $$
DROP PROCEDURE IF EXISTS usp_RegisterUser$$

CREATE PROCEDURE usp_RegisterUser(
    IN in_firstname VARCHAR(128),
    IN in_lastname VARCHAR(128),
    IN in_email VARCHAR(255),
    IN in_password VARCHAR(255),
    IN in_phone_number VARCHAR(15),
    IN in_gender TINYINT,
    IN in_date_of_birth DATE,
    IN in_address_line1 VARCHAR(255),
    IN in_address_line2 VARCHAR(255),
    IN in_country_id BIGINT UNSIGNED,
    IN in_region_id BIGINT UNSIGNED,
    IN in_city VARCHAR(255),
    IN in_postal_code VARCHAR(20),
    IN in_avatar_url VARCHAR(512)
)
proc_label:BEGIN
    DECLARE v_user_id BIGINT UNSIGNED;
    DECLARE v_record_exists INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF in_firstname IS NULL OR TRIM(in_firstname) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'First name is required.';
    END IF;
    IF in_lastname IS NULL OR TRIM(in_lastname) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Last name is required.';
    END IF;
    IF in_phone_number IS NULL OR TRIM(in_phone_number) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Phone number is required.';
    END IF;
    IF in_address_line1 IS NULL OR TRIM(in_address_line1) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Address line 1 is required.';
    END IF;
    IF in_city IS NULL OR TRIM(in_city) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'City is required.';
    END IF;
    IF in_postal_code IS NULL OR TRIM(in_postal_code) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Postal code is required.';
    END IF;

    IF in_email IS NULL OR NOT in_email REGEXP '^[a-zA-Z0-9][a-zA-Z0-9._-]*@[a-zA-Z0-9][a-zA-Z0-9._-]*\\.[a-zA-Z]{2,4}$' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A valid email address is required.';
    END IF;

    SELECT COUNT(1) INTO v_record_exists FROM tblUsers WHERE email = in_email;
    IF v_record_exists > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This email address is already registered.';
    END IF;

    IF in_password IS NULL OR NOT in_password REGEXP '^[a-f0-9]{64}$' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid password format. A SHA-256 hash is expected.';
    END IF;

    IF in_gender NOT IN (1, 2, 3) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid gender specified. Allowed values are 1, 2, 3.';
    END IF;

    IF in_date_of_birth IS NULL OR in_date_of_birth > CURDATE() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Date of birth cannot be in the future.';
    END IF;

    SELECT COUNT(1) INTO v_record_exists FROM tblCountries WHERE id = in_country_id;
    IF v_record_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The specified country does not exist.';
    END IF;

    SELECT COUNT(1) INTO v_record_exists FROM tblStates WHERE id = in_region_id AND country_id = in_country_id;
    IF v_record_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The specified region is not valid for the selected country.';
    END IF;

    START TRANSACTION;

    INSERT INTO tblUsers (firstname, lastname, email, `password`, created_by)
    VALUES (TRIM(in_firstname), TRIM(in_lastname), TRIM(in_email), in_password, 0);
    SET v_user_id = LAST_INSERT_ID();

    UPDATE tblUsers SET created_by = v_user_id WHERE id = v_user_id;

    INSERT INTO tblUserProfiles (
        user_id,
        phone_number,
        gender,
        date_of_birth,
        address_line1,
        address_line2,
        country_id,
        region_id,
        city,
        postal_code,
        avatar_url,
        created_by
    ) VALUES (
        v_user_id,
        TRIM(in_phone_number),
        in_gender,
        in_date_of_birth,
        TRIM(in_address_line1),
        IF(in_address_line2 IS NULL OR TRIM(in_address_line2) = '', NULL, TRIM(in_address_line2)),
        in_country_id,
        in_region_id,
        TRIM(in_city),
        TRIM(in_postal_code),
        IF(in_avatar_url IS NULL OR TRIM(in_avatar_url) = '', NULL, TRIM(in_avatar_url)),
        v_user_id
    );

    COMMIT;

    SELECT v_user_id AS new_user_id;

END$$

DELIMITER ;