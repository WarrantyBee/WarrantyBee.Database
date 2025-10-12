DELIMITER $$
DROP PROCEDURE IF EXISTS usp_GetUser$$

CREATE PROCEDURE usp_GetUser(
    IN in_id BIGINT UNSIGNED,
    IN in_email VARCHAR(255)
)
proc_label:BEGIN

    IF in_id IS NULL AND (in_email IS NULL OR TRIM(in_email) = '') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Either a user ID or an email must be provided.';
        LEAVE proc_label;
    END IF;

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
        s.iso_code AS region_iso
    FROM
        tblUsers u
    LEFT JOIN tblUserProfiles up ON u.id = up.user_id
    LEFT JOIN tblCountries c ON up.country_id = c.id
    LEFT JOIN tblStates s ON up.region_id = s.id
    WHERE (in_id IS NOT NULL AND u.id = in_id)
    OR (in_email IS NOT NULL AND u.email = in_email)
    LIMIT 1;

END$$

DELIMITER ;

SELECT "usp_GetUser created successfully" AS message;