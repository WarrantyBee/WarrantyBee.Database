DELIMITER $$
DROP PROCEDURE IF EXISTS usp_GetCurrencies$$

CREATE PROCEDURE usp_GetCurrencies(
    IN in_id BIGINT UNSIGNED
)
BEGIN
    SELECT
        id,
        iso_code,
        numeric_code,
        name,
        symbol,
        minor_unit
    FROM tblCurrencies
    WHERE void = 0 AND (in_id IS NULL OR id = in_id)
    ORDER BY name;
END$$

DELIMITER ;

SELECT 'usp_GetCurrencies created successfully.' AS message;