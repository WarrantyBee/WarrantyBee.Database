-- =============================================
-- ufn_DoesTableExist
-- Checks if a specific table exists within the current database.
--
-- Parameters:
--   @in_table_name - The name of the table to check for existence.
--
-- Returns:
--   1 (TRUE) if the table exists in the current database, otherwise 0 (FALSE).
-- =============================================

IF OBJECT_ID('dbo.ufn_DoesTableExist', 'FN') IS NOT NULL
    DROP FUNCTION dbo.ufn_DoesTableExist;
GO

CREATE FUNCTION dbo.ufn_DoesTableExist(@in_table_name NVARCHAR(128))
RETURNS BIT
AS
BEGIN
    DECLARE @exists BIT = 0;

    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = @in_table_name AND schema_id = SCHEMA_ID('dbo'))
    BEGIN
        SET @exists = 1;
    END

    RETURN @exists;
END
GO


