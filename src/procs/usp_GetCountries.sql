DELIMITER $$
DROP PROCEDURE IF EXISTS usp_GetCountries$$

CREATE PROCEDURE usp_GetCountries(
    IN in_id BIGINT UNSIGNED
)
BEGIN
    SELECT
        c.id,
        c.iso2_code,
        c.iso3_code,
        c.numeric_code,
        c.name,
        c.official_name,
        c.capital,
        c.phone_code,
        cur.id AS currency_id,
        cur.name AS currency_name,
        cur.symbol AS currency_symbol
    FROM
        tblCountries c
    LEFT JOIN tblCurrencies cur ON c.currency_id = cur.id
    WHERE c.void = 0 AND (in_id IS NULL OR c.id = in_id)
    ORDER BY c.name;
END$$

DELIMITER ;

SELECT 'usp_GetCountries created successfully.' AS message;