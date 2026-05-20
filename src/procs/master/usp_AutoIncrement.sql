-- =============================================
-- usp_AutoIncrement
-- Ensures a column is an IDENTITY column.
--
-- Parameters:
--   @in_table_name   - The name of the table.
--   @in_column_name  - The name of the column.
--
-- Notes:
--   - In T-SQL, IDENTITY should ideally be set during table creation.
--   - This procedure checks if the column is already an identity column.
-- =============================================

IF OBJECT_ID('dbo.usp_AutoIncrement', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_AutoIncrement;
GO

CREATE PROCEDURE dbo.usp_AutoIncrement
    @in_table_name NVARCHAR(128),
    @in_column_name NVARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;

    IF COLUMNPROPERTY(OBJECT_ID(@in_table_name), @in_column_name, 'IsIdentity') = 1
    BEGIN
        PRINT 'Column ' + @in_column_name + ' in table ' + @in_table_name + ' is already an IDENTITY column.';
    END
    ELSE
    BEGIN
        -- Since we cannot easily alter a column to be IDENTITY in SQL Server without recreating the table,
        -- and our usp_CreateTable already handles this for the primary key, we emit a warning for other columns.
        PRINT 'WARNING: Column ' + @in_column_name + ' is not an IDENTITY column. In SQL Server, IDENTITY must be set during column creation.';
    END
END
GO



