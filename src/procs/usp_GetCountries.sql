DELIMITER $$
DROP PROCEDURE IF EXISTS usp_GetCountries$$

CREATE PROCEDURE usp_GetCountries()
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
        JSON_OBJECT(
            'id', cur.id,
            'iso', cur.iso_code,
            'code', cur.numeric_code,
            'name', cur.name,
            'symbol', cur.symbol,
            'minorUnit', cur.minor_unit
        ) as currency,
        (
            SELECT JSON_ARRAYAGG(
                JSON_OBJECT(
                    'id', s.id,
                    'name', s.name,
                    'iso', s.iso_code,
                    'capital', s.capital,
                    'timezoneId', s.timezone_id
                )
            )
            FROM tblStates s
            WHERE s.country_id = c.id AND s.void = 0
        ) as states,
        (
            SELECT JSON_ARRAYAGG(
                JSON_OBJECT(
                    'id', cul.id,
                    'iso', cul.iso_code,
                    'rtl', cul.rtl,
                    'language', JSON_OBJECT(
                        'id', l.id,
                        'name', l.name,
                        'nativeName', l.native_name,
                        'iso', l.iso_code
                    )
                )
            )
            FROM tblCultures cul
            JOIN tblLanguages l ON cul.language_id = l.id
            WHERE cul.country_id = c.id AND cul.void = 0
        ) as cultures,
        (
            SELECT JSON_ARRAYAGG(
                JSON_OBJECT(
                    'id', t.id,
                    'name', t.name,
                    'abbreviation', t.abbreviation,
                    'offsetMinutes', t.utc_offset_minutes,
                    'currentOffsetMinutes', t.current_offset_minutes,
                    'dst', t.observes_dst
                )
            )
            FROM (SELECT DISTINCT tz.* FROM tblStates s JOIN tblTimeZones tz ON s.timezone_id = tz.id WHERE s.country_id = c.id AND s.void = 0) t
        ) as timezones
    FROM
        tblCountries c
    LEFT JOIN
        tblCurrencies cur ON c.currency_id = cur.id
    WHERE
        c.void = 0;
END$$

DELIMITER ;

SELECT 'usp_GetCountries created successfully.' AS message;
