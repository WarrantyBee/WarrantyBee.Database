-- =============================================
-- usp_AlterColumn
-- Modifies an existing column in a specified table.
--
-- Parameters:
--   @in_table_name    - The name of the table.
--   @in_column_name   - The name of the column to alter.
--   @in_data_type     - The new data type for the column.
--   @in_required      - Whether the column should be NOT NULL. 1 for TRUE, 0 for FALSE.
--   @in_default_value - The new default value (optional).
-- =============================================

IF OBJECT_ID('dbo.usp_AlterColumn', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_AlterColumn;
GO

CREATE PROCEDURE dbo.usp_AlterColumn
    @in_table_name NVARCHAR(128),
    @in_column_name NVARCHAR(128),
    @in_data_type NVARCHAR(128),
    @in_required BIT = 0,
    @in_default_value NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Check if table and column exist
        IF dbo.ufn_DoesColumnExist(@in_table_name, @in_column_name) = 0
        BEGIN
            PRINT 'Alter column failed: Column ' + @in_column_name + ' in table ' + @in_table_name + ' does not exist.';
            RETURN;
        END

        DECLARE @data_type NVARCHAR(128) = UPPER(@in_data_type);
        IF @data_type LIKE '%BIGINT UNSIGNED%' SET @data_type = REPLACE(@data_type, N'BIGINT', 'BIGINT');
        IF @data_type = N'BIT' SET @data_type = 'BIT';
        IF @data_type = N'DATETIME2' SET @data_type = 'DATETIME2';

        -- Build the ALTER COLUMN statement
        DECLARE @sql NVARCHAR(MAX) = N'ALTER TABLE dbo.' + QUOTENAME(@in_table_name) + 
                                     N' ALTER COLUMN ' + QUOTENAME(@in_column_name) + N' ' + @data_type;

        IF @in_required = 1
            SET @sql = @sql + N' NOT NULL';
        ELSE
            SET @sql = @sql + N' NULL';

        EXEC sp_executesql @sql;

        -- Default value handling is more complex in T-SQL (requires dropping old and adding new constraint)
        -- We will just print a note for now, or implement if really needed.
        IF @in_default_value IS NOT NULL
        BEGIN
            PRINT 'Note: Default value change for ' + @in_column_name + ' was requested but is not fully implemented in this T-SQL migration helper.';
        END

        PRINT 'Column ' + @in_column_name + ' altered successfully in table ' + @in_table_name + '.';
    END TRY
    BEGIN CATCH
        PRINT 'Alter column failed: ' + ERROR_MESSAGE();
    END CATCH
END
GO


