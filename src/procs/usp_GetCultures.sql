DELIMITER $
DROP PROCEDURE IF EXISTS usp_GetCultures$

CREATE PROCEDURE usp_GetCultures(
    IN in_id BIGINT UNSIGNED,
    IN in_language_id BIGINT UNSIGNED
)
BEGIN
    SELECT
        cu.id,
        cu.iso_code,
        cu.rtl,
        cu.language_id,
        cu.country_id,
        c.name,
        l.name AS language_name,
        l.iso_code AS language_iso_code,
        l.native_name AS language_native_name
    FROM tblCultures cu
    LEFT JOIN tblCountries c ON cu.country_id = c.id
    LEFT JOIN tblLanguages l ON cu.language_id = l.id
    WHERE cu.void = 0 AND (in_id IS NULL OR cu.id = in_id)
    AND (in_language_id IS NULL OR cu.language_id = in_language_id)
    ORDER BY l.name;
END$

DELIMITER ;

SELECT 'usp_GetCultures created successfully.' AS message;
