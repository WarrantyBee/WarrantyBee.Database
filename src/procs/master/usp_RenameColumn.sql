-- =============================================
-- usp_RenameColumn
-- Renames an existing column in a specified table.
--
-- Parameters:
--   @in_table_name      - The name of the table.
--   @in_old_column_name - The current name of the column.
--   @in_new_column_name - The new name for the column.
-- =============================================

IF OBJECT_ID('dbo.usp_RenameColumn', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_RenameColumn;
GO

CREATE PROCEDURE dbo.usp_RenameColumn
    @in_table_name NVARCHAR(128),
    @in_old_column_name NVARCHAR(128),
    @in_new_column_name NVARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Check if table and old column exist
        IF dbo.ufn_DoesColumnExist(@in_table_name, @in_old_column_name) = 1
        BEGIN
            -- SQL Server built-in procedure for renaming
            DECLARE @object_name NVARCHAR(255) = QUOTENAME(@in_table_name) + N'.' + QUOTENAME(@in_old_column_name);
            
            EXEC sp_rename @object_name, @in_new_column_name, 'COLUMN';

            PRINT 'Column ' + @in_old_column_name + ' in table ' + @in_table_name + ' renamed successfully to ' + @in_new_column_name + '.';
        END
        ELSE
        BEGIN
            PRINT 'Rename column failed: Column ' + @in_old_column_name + ' does not exist in table ' + @in_table_name + '.';
        END
    END TRY
    BEGIN CATCH
        PRINT 'Rename column failed: ' + ERROR_MESSAGE();
    END CATCH
END
GO


