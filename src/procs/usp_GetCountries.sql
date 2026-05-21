IF OBJECT_ID('dbo.usp_GetCountries', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_GetCountries;
GO

CREATE PROCEDURE dbo.usp_GetCountries
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        c.id,
        c.iso2_code AS iso2,
        c.iso3_code AS iso3,
        c.numeric_code AS code,
        c.name,
        c.official_name,
        c.capital,
        c.phone_code,
        (
            SELECT 
                cur.id AS id,
                cur.iso_code AS iso,
                cur.numeric_code AS code,
                cur.name AS name,
                cur.symbol AS symbol,
                cur.minor_unit AS minorUnit
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        ) as currency,
        (
            SELECT 
                s.id AS id,
                s.name AS name,
                s.iso_code AS iso,
                s.capital AS capital,
                s.timezone_id AS timezoneId
            FROM tblStates s
            WHERE s.country_id = c.id AND s.void = 0
            FOR JSON PATH
        ) as regions,
        (
            SELECT 
                cul.id AS id,
                cul.iso_code AS iso,
                cul.rtl AS rtl,
                l.id AS [language.id],
                l.name AS [language.name],
                l.native_name AS [language.nativeName],
                l.iso_code AS [language.iso]
            FROM tblCultures cul
            JOIN tblLanguages l ON cul.language_id = l.id
            WHERE cul.country_id = c.id AND cul.void = 0
            FOR JSON PATH
        ) as cultures,
        (
            SELECT 
                t.id AS id,
                t.name AS name,
                t.abbreviation AS abbreviation,
                t.utc_offset_minutes AS offsetMinutes,
                t.current_offset_minutes AS currentOffsetMinutes,
                t.observes_dst AS dst
            FROM (SELECT DISTINCT tz.* FROM tblStates s JOIN tblTimeZones tz ON s.timezone_id = tz.id WHERE s.country_id = c.id AND s.void = 0) t
            FOR JSON PATH
        ) as timezones
    FROM
        tblCountries c
    LEFT JOIN
        tblCurrencies cur ON c.currency_id = cur.id
    WHERE
        c.void = 0;
END
GO

PRINT 'usp_GetCountries created successfully.';
