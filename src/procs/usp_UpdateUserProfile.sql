/*
-- ===============================================================================================================================================
-- usp_UpdateUserProfile
-- Updates a user's profile information. This procedure functions like a PATCH operation,
-- only updating the fields for which non-NULL values are provided.
--
-- Parameters:
--   in_user_id:        The ID of the user whose profile is to be updated.
--   in_address_line1:  The user's primary address line.
--   in_address_line2:  The user's secondary address line (optional).
--   in_phone_code:     The user's country phone code.
--   in_phone_number:   The user's phone number.
--   in_country_id:     The ID of the user's country.
--   in_region_id:      The ID of the user's state or region.
--   in_city:           The user's city.
--   in_postal_code:    The user's postal code.
--   in_avatar_url:     The URL of the user's avatar image (optional).
--
-- Returns:     A result set with a 'success' status (1 for success, 0 for failure) and a 'message'.
-- ===============================================================================================================================================
*/
DELIMITER $$
DROP PROCEDURE IF EXISTS usp_UpdateUserProfile$$

CREATE PROCEDURE usp_UpdateUserProfile(
    IN in_user_id BIGINT UNSIGNED,
    IN in_address_line1 VARCHAR(255),
    IN in_address_line2 VARCHAR(255),
    IN in_phone_code VARCHAR(8),
    IN in_phone_number VARCHAR(15),
    IN in_country_id BIGINT UNSIGNED,
    IN in_region_id BIGINT UNSIGNED,
    IN in_city VARCHAR(255),
    IN in_postal_code VARCHAR(20),
    IN in_avatar_url VARCHAR(512)
)
proc_label:BEGIN
    DECLARE v_record_exists INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        DECLARE v_error_message VARCHAR(255);
        GET DIAGNOSTICS CONDITION 1 v_error_message = MESSAGE_TEXT;
        ROLLBACK;
        SELECT 0 AS success, v_error_message AS message;
    END;

    SELECT COUNT(1) INTO v_record_exists FROM tblUsers WHERE id = in_user_id;
    IF v_record_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The specified user does not exist.';
    END IF;

    IF in_country_id IS NOT NULL THEN
        SELECT COUNT(1) INTO v_record_exists FROM tblCountries WHERE id = in_country_id;
        IF v_record_exists = 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_text = 'The specified country does not exist.';
        END IF;
    END IF;

    IF in_region_id IS NOT NULL THEN
        SELECT COUNT(1) INTO v_record_exists FROM tblStates WHERE id = in_region_id AND country_id = IFNULL(in_country_id, (SELECT country_id from tblUserProfiles WHERE user_id = in_user_id));
        IF v_record_exists = 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The specified region is not valid for the selected country.';
        END IF;
    END IF;

    START TRANSACTION;

    UPDATE tblUserProfiles
    SET
        address_line1 = IFNULL(TRIM(in_address_line1), address_line1),
        address_line2 = IF(in_address_line2 IS NULL, address_line2, TRIM(in_address_line2)),
        phone_code = IFNULL(TRIM(in_phone_code), phone_code),
        phone_number = IFNULL(TRIM(in_phone_number), phone_number),
        country_id = IFNULL(in_country_id, country_id),
        region_id = IFNULL(in_region_id, region_id),
        city = IFNULL(TRIM(in_city), city),
        postal_code = IFNULL(TRIM(in_postal_code), postal_code),
        avatar_url = IF(in_avatar_url IS NULL, avatar_url, TRIM(in_avatar_url))
    WHERE
        user_id = in_user_id;

    COMMIT;

    SELECT 1 AS success, 'User profile updated successfully.' AS message;

END$$

DELIMITER ;

SELECT 'usp_UpdateUserProfile created successfully.' AS message;