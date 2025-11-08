DELIMITER $$
DROP PROCEDURE IF EXISTS usp_GetUser$$

CREATE PROCEDURE usp_GetUser(
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
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Either a user ID or an email must be provided.';
    END IF;

    SELECT COUNT(1) INTO v_user_exists
    FROM tblUsers u
    WHERE (in_id IS NOT NULL AND u.id = in_id) OR (in_email IS NOT NULL AND u.email = in_email);

    IF v_user_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User not found.';
    END IF;

    SELECT 0 AS status, 'Success' AS message;

    SELECT
        u.id,
        BIN_TO_UUID(u.internal_id) AS internal_id,
        u.firstname,
        u.lastname,
        u.email,
        u.created_at,
        u.updated_at,
        up.phone_number,
        up.gender,
        up.date_of_birth,
        up.address_line1,
        up.address_line2,
        up.city,
        up.postal_code,
        up.avatar_url,
        c.id AS country_id,
        c.name AS country_name,
        c.iso3_code AS country_iso3,
        s.id AS region_id,
        s.name AS region_name,
        s.iso_code AS region_iso,
        tz.id AS timezone_id,
        tz.name AS timezone_name,
        tz.abbreviation AS timezone_abbreviation,
        tz.utc_offset_minutes AS timezone_utc_offset_minutes,
        tz.observes_dst AS timezone_observes_dst,
        tz.current_offset_minutes AS timezone_current_offset_minutes,
        cur.id AS currency_id,
        cur.name AS currency_name,
        cur.numeric_code AS currency_code,
        cur.iso_code AS currency_iso_code,
        cur.symbol AS currency_symbol,
        cur.minor_unit AS currency_minor_unit,
        u.is_2fa_enabled
    FROM
        tblUsers u
    LEFT JOIN tblUserProfiles up ON u.id = up.user_id
    LEFT JOIN tblCountries c ON up.country_id = c.id
    LEFT JOIN tblStates s ON up.region_id = s.id
    LEFT JOIN tblTimeZones tz on tz.id = s.timezone_id
    LEFT JOIN tblCurrencies cur on cur.id = c.currency_id
    WHERE (in_id IS NOT NULL AND u.id = in_id)
    OR (in_email IS NOT NULL AND u.email = in_email)
    LIMIT 1;

END$$

DELIMITER ;

SELECT 'usp_GetUser created successfully.' AS message;