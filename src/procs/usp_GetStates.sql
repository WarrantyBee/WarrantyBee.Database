DELIMITER $
DROP PROCEDURE IF EXISTS usp_GetStates$

CREATE PROCEDURE usp_GetStates(
    IN in_id BIGINT UNSIGNED,
    IN in_country_id BIGINT UNSIGNED
)
BEGIN
    SELECT
        s.id,
        s.name,
        s.official_name,
        s.iso_code,
        s.capital,
        s.phone_code,
        s.country_id,
        s.timezone_id,
        tz.name AS timezone_name,
        tz.abbreviation AS timezone_abbreviation,
        tz.utc_offset_minutes AS timezone_utc_offset_minutes,
        tz.observes_dst AS timezone_observes_dst,
        tz.current_offset_minutes AS timezone_current_offset_minutes
    FROM tblStates s
    LEFT JOIN tblTimeZones tz ON s.timezone_id = tz.id
    WHERE s.void = 0 AND (in_id IS NULL OR s.id = in_id)
    AND (in_country_id IS NULL OR s.country_id = in_country_id)
    ORDER BY s.name;
END$

DELIMITER ;

SELECT 'usp_GetStates created successfully.' AS message;