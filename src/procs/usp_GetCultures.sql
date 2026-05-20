IF OBJECT_ID('dbo.usp_GetCultures', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_GetCultures;
GO

CREATE PROCEDURE dbo.usp_GetCultures(
    @in_id BIGINT = NULL,
    @in_language_id BIGINT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

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
    WHERE cu.void = 0 AND (@in_id IS NULL OR cu.id = @in_id)
    AND (@in_language_id IS NULL OR cu.language_id = @in_language_id)
    ORDER BY l.name;
END
GO

PRINT 'usp_GetCultures created successfully.';



