-- =============================================
-- usp_DropColumn
-- Removes a column from a table if it exists.
--
-- Parameters:
--   @in_table_name  - The name of the table.
--   @in_column_name - The name of the column to drop.
-- =============================================

IF OBJECT_ID('dbo.usp_DropColumn', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_DropColumn;
GO

CREATE PROCEDURE dbo.usp_DropColumn
    @in_table_name NVARCHAR(128),
    @in_column_name NVARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Check if table and column exist
        IF dbo.ufn_DoesColumnExist(@in_table_name, @in_column_name) = 1
        BEGIN
            -- In SQL Server, we might need to drop dependent constraints first.
            -- This helper simplifies that by only dropping the column if possible.
            DECLARE @sql NVARCHAR(MAX) = N'ALTER TABLE dbo.' + QUOTENAME(@in_table_name) + 
                                         N' DROP COLUMN ' + QUOTENAME(@in_column_name);
            EXEC sp_executesql @sql;

            PRINT 'Column ' + @in_column_name + ' dropped successfully from table ' + @in_table_name + '.';
        END
        ELSE
        BEGIN
            PRINT 'Column ' + @in_column_name + ' does not exist in table ' + @in_table_name + '.';
        END
    END TRY
    BEGIN CATCH
        PRINT 'Drop column failed: ' + ERROR_MESSAGE();
    END CATCH
END
GO

