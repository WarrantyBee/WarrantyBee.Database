-- =============================================
-- usp_MarkRequired
-- Marks an existing column in a specified table as NOT NULL.
--
-- Parameters:
--   @in_table_name  - The name of the table.
--   @in_column_name - The name of the column to mark as required.
-- =============================================

IF OBJECT_ID('dbo.usp_MarkRequired', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_MarkRequired;
GO

CREATE PROCEDURE dbo.usp_MarkRequired
    @in_table_name NVARCHAR(128),
    @in_column_name NVARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Check if table and column exist
        IF dbo.ufn_DoesColumnExist(@in_table_name, @in_column_name) = 1
        BEGIN
            -- Get current data type
            DECLARE @data_type NVARCHAR(128);
            SELECT @data_type = DATA_TYPE + 
                                CASE 
                                    WHEN CHARACTER_MAXIMUM_LENGTH IS NOT NULL THEN '(' + CAST(CHARACTER_MAXIMUM_LENGTH AS NVARCHAR) + ')'
                                    ELSE ''
                                END
            FROM INFORMATION_SCHEMA.COLUMNS 
            WHERE TABLE_NAME = @in_table_name AND COLUMN_NAME = @in_column_name;

            DECLARE @sql NVARCHAR(MAX) = N'ALTER TABLE dbo.' + QUOTENAME(@in_table_name) + 
                                         N' ALTER COLUMN ' + QUOTENAME(@in_column_name) + N' ' + @data_type + N' NOT NULL';
            EXEC sp_executesql @sql;

            PRINT 'Column ' + @in_column_name + ' in table ' + @in_table_name + ' is now marked as NOT NULL.';
        END
        ELSE
        BEGIN
            PRINT 'Mark required failed: Column ' + @in_column_name + ' does not exist in table ' + @in_table_name + '.';
        END
    END TRY
    BEGIN CATCH
        PRINT 'Mark required failed: ' + ERROR_MESSAGE();
    END CATCH
END
GO


