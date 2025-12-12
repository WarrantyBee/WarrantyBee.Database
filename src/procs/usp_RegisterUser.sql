DELIMITER $$
DROP PROCEDURE IF EXISTS usp_RegisterUser$$

CREATE PROCEDURE usp_RegisterUser(
    IN in_firstname VARCHAR(128),
    IN in_lastname VARCHAR(128),
    IN in_email VARCHAR(255),
    IN in_password VARCHAR(255),
    IN in_accepted_tnc BOOLEAN,
    IN in_accepted_pp BOOLEAN,
    IN in_phone_code VARCHAR(8),
    IN in_phone_number VARCHAR(15),
    IN in_gender TINYINT,
    IN in_date_of_birth DATE,
    IN in_address_line1 VARCHAR(255),
    IN in_address_line2 VARCHAR(255),
    IN in_country_id BIGINT UNSIGNED,
    IN in_region_id BIGINT UNSIGNED,
    IN in_city VARCHAR(255),
    IN in_postal_code VARCHAR(20),
    IN in_avatar_url VARCHAR(512),
    IN in_culture_id BIGINT UNSIGNED,
    IN in_auth_provider TINYINT,
    IN in_auth_provider_user_id VARCHAR(50)
)
proc_label:BEGIN
    DECLARE v_user_id BIGINT UNSIGNED;
    DECLARE v_record_exists INT DEFAULT 0;
    DECLARE v_not_accepted BOOLEAN DEFAULT FALSE;
    DECLARE v_disabled BOOLEAN DEFAULT FALSE;
    DECLARE v_gender_male TINYINT DEFAULT 1;
    DECLARE v_gender_female TINYINT DEFAULT 2;
    DECLARE v_gender_not_specified TINYINT DEFAULT 3;
    DECLARE v_auth_provider_internal TINYINT DEFAULT 1;
    DECLARE v_auth_provider_facebook TINYINT DEFAULT 2;
    DECLARE v_auth_provider_google TINYINT DEFAULT 3;
    DECLARE v_auth_provider_linkedin TINYINT DEFAULT 4;
    DECLARE v_customer_role BIGINT UNSIGNED DEFAULT NULL;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        DECLARE v_error_message VARCHAR(255);
        GET DIAGNOSTICS CONDITION 1 v_error_message = MESSAGE_TEXT;
        ROLLBACK;
        SELECT NULL AS inserted_id, v_error_message AS message;
    END;

    IF in_accepted_tnc = v_not_accepted THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Terms and Conditions must be accepted.';
    END IF;
    
    IF in_accepted_pp = v_not_accepted THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Privacy Policy must be accepted.';
    END IF;
    
    IF in_firstname IS NULL OR TRIM(in_firstname) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'First name is required.';
    END IF;
    
    IF in_lastname IS NULL OR TRIM(in_lastname) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Last name is required.';
    END IF;
    
    IF in_phone_code IS NULL OR TRIM(in_phone_code) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Phone code is required.';
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

    IF in_gender NOT IN (v_gender_male, v_gender_female, v_gender_not_specified) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid gender specified. Allowed values are 1, 2, 3.';
    END IF;

    IF in_date_of_birth IS NULL OR in_date_of_birth > CURDATE() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Date of birth cannot be in the future.';
    END IF;

    SELECT COUNT(1) INTO v_record_exists FROM tblCountries WHERE id = in_country_id;
    IF v_record_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_text = 'The specified country does not exist.';
    END IF;

    SELECT COUNT(1) INTO v_record_exists FROM tblStates WHERE id = in_region_id AND country_id = in_country_id;
    IF v_record_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The specified region is not valid for the selected country.';
    END IF;

    SELECT COUNT(1) INTO v_record_exists FROM tblCultures WHERE id = in_culture_id;
    IF v_record_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The specified culture does not exist.';
    END IF;

    IF in_auth_provider NOT IN (v_auth_provider_internal, v_auth_provider_facebook, v_auth_provider_google, v_auth_provider_linkedin) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The specified auth provider is not supported.';
    END IF;

    IF in_auth_provider = v_auth_provider_internal AND
        (in_auth_provider_user_id IS NULL OR TRIM(in_auth_provider_user_id) = '') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The auth provider user identifier is required.';
    END IF;

    SELECT id INTO v_customer_role
    FROM tblRoles
    WHERE name = 'customer';

    START TRANSACTION;

    INSERT INTO tblUsers (
        firstname,
        lastname,
        email,
        `password`,
        is_2fa_enabled,
        accepted_tnc,
        accepted_pp,
        auth_provider,
        auth_provider_user_id,
        role_id
    )
    VALUES (
        TRIM(in_firstname),
        TRIM(in_lastname),
        TRIM(in_email),
        IF(in_auth_provider = v_auth_provider_internal, in_password, NULL),
        v_disabled,
        in_accepted_tnc,
        in_accepted_pp,
        in_auth_provider,
        in_auth_provider_user_id,
        v_customer_role
    );
    SET v_user_id = LAST_INSERT_ID();

    INSERT INTO tblUserProfiles (
        user_id,
        phone_code,
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
        culture_id
    ) VALUES (
        v_user_id,
        TRIM(in_phone_code),
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
        in_culture_id
    );

    COMMIT;

    SELECT v_user_id AS inserted_id, 'Success' AS message;

END$$

DELIMITER ;

SELECT 'usp_RegisterUser created successfully.' AS message;