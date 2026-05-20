-- =============================================
-- usp_AddColumn
-- Adds a column to a specified table if it does not already exist.
--
-- Parameters:
--   @in_table_name    - The name of the table to alter.
--   @in_column_name   - The name of the column to add.
--   @in_data_type     - The data type of the new column (e.g., 'VARCHAR(255)', 'INT').
--   @in_default_value - The default value for the column (NULL for no default).
--   @in_required      - Whether the column is required (NOT NULL). 1 for TRUE, 0 for FALSE.
-- =============================================

IF OBJECT_ID('dbo.usp_AddColumn', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_AddColumn;
GO

CREATE PROCEDURE dbo.usp_AddColumn
    @in_table_name NVARCHAR(128),
    @in_column_name NVARCHAR(128),
    @in_data_type NVARCHAR(128),
    @in_default_value NVARCHAR(MAX) = NULL,
    @in_required BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Check if table exists
        IF dbo.ufn_DoesTableExist(@in_table_name) = 0
        BEGIN
            PRINT 'Column ' + @in_column_name + ' addition failed: Table ' + @in_table_name + ' does not exist.';
            RETURN;
        END

        -- Check if column already exists
        IF dbo.ufn_DoesColumnExist(@in_table_name, @in_column_name) = 1
        BEGIN
            PRINT 'Column ' + @in_column_name + ' already exists in table ' + @in_table_name + '.';
            RETURN;
        END

        -- Start building the ALTER TABLE statement
        -- Map MySQL BIGINT UNSIGNED to BIGINT
        DECLARE @data_type NVARCHAR(128) = UPPER(@in_data_type);
        IF @data_type LIKE '%BIGINT UNSIGNED%' SET @data_type = REPLACE(@data_type, N'BIGINT', 'BIGINT');
        IF @data_type = N'BIT' SET @data_type = 'BIT';
        IF @data_type = N'DATETIME2' SET @data_type = 'DATETIME2';

        DECLARE @sql NVARCHAR(MAX) = N'ALTER TABLE dbo.' + QUOTENAME(@in_table_name) + 
                                     N' ADD ' + QUOTENAME(@in_column_name) + N' ' + @data_type;

        -- Add NOT NULL if required
        IF @in_required = 1
        BEGIN
            SET @sql = @sql + N' NOT NULL';
        END
        ELSE
        BEGIN
            SET @sql = @sql + N' NULL';
        END

        -- Handle default value
        IF @in_default_value IS NOT NULL AND @in_default_value <> ''
        BEGIN
            DECLARE @def NVARCHAR(MAX) = @in_default_value;
            -- Simple mapping for common MySQL defaults
            IF @def = 'CURRENT_TIMESTAMP' OR @def = 'NOW()' SET @def = 'GETUTCDATE()';
            
            SET @sql = @sql + N' DEFAULT ' + @def;
        END

        EXEC sp_executesql @sql;

        PRINT 'Column ' + @in_column_name + ' added successfully to table ' + @in_table_name + '.';
    END TRY
    BEGIN CATCH
        PRINT 'Column ' + @in_column_name + ' addition failed: ' + ERROR_MESSAGE();
    END CATCH
END
GO

