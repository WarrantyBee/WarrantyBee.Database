DELIMITER $$
DROP PROCEDURE IF EXISTS usp_GetTimeZones$$

CREATE PROCEDURE usp_GetTimeZones(
    IN in_id BIGINT UNSIGNED
)
BEGIN
    SELECT
        id,
        name,
        abbreviation,
        utc_offset_minutes,
        observes_dst,
        current_offset_minutes
    FROM tblTimeZones
    WHERE (in_id IS NULL OR id = in_id)
    ORDER BY utc_offset_minutes, name;
END$$

DELIMITER ;

SELECT 'usp_GetTimeZones created successfully.' AS message;