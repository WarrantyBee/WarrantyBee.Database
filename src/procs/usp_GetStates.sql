DELIMITER $$
DROP PROCEDURE IF EXISTS usp_GetStates$$

CREATE PROCEDURE usp_GetStates(
    IN in_id BIGINT UNSIGNED
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
        c.name AS country_name,
        s.timezone_id,
        tz.name AS timezone_name
    FROM tblStates s
    LEFT JOIN tblCountries c ON s.country_id = c.id
    LEFT JOIN tblTimeZones tz ON s.timezone_id = tz.id
    WHERE s.void = 0 AND (in_id IS NULL OR s.id = in_id)
    ORDER BY c.name, s.name;
END$$

DELIMITER ;