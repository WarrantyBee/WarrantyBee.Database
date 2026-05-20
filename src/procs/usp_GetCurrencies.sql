IF OBJECT_ID('dbo.usp_GetCurrencies', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_GetCurrencies;
GO

CREATE PROCEDURE dbo.usp_GetCurrencies(
    @in_id BIGINT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        id,
        iso_code,
        numeric_code,
        name,
        symbol,
        minor_unit
    FROM tblCurrencies
    WHERE void = 0 AND (@in_id IS NULL OR id = @in_id)
    ORDER BY name;
END
GO

PRINT 'usp_GetCurrencies created successfully.';

