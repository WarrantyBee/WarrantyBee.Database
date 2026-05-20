-- =============================================
-- ufn_DoesColumnExist
-- Checks if a specific column exists in a given table within the current database.
--
-- Parameters:
--   @in_table_name   - The name of the table to check.
--   @in_column_name  - The name of the column to check for existence.
--
-- Returns:
--   1 (TRUE) if the column exists in the specified table, otherwise 0 (FALSE).
-- =============================================

IF OBJECT_ID('dbo.ufn_DoesColumnExist', 'FN') IS NOT NULL
    DROP FUNCTION dbo.ufn_DoesColumnExist;
GO

CREATE FUNCTION dbo.ufn_DoesColumnExist(
    @in_table_name NVARCHAR(128),
    @in_column_name NVARCHAR(128)
)
RETURNS BIT
AS
BEGIN
    DECLARE @exists BIT = 0;

    IF EXISTS (
        SELECT 1 
        FROM sys.columns c
        JOIN sys.tables t ON c.object_id = t.object_id
        WHERE t.name = @in_table_name 
          AND c.name = @in_column_name
          AND t.schema_id = SCHEMA_ID('dbo')
    )
    BEGIN
        SET @exists = 1;
    END

    RETURN @exists;
END
GO



