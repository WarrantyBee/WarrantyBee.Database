-- =============================================
-- usp_CreateIndex
-- Adds an index to a specified table and columns if it does not already exist.
--
-- Parameters:
--   @in_table_name   - The name of the table.
--   @in_column_names - A comma-separated string of column names.
-- =============================================

IF OBJECT_ID('dbo.usp_CreateIndex', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_CreateIndex;
GO

CREATE PROCEDURE dbo.usp_CreateIndex
    @in_table_name NVARCHAR(128),
    @in_column_names NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Check if table exists
        IF dbo.ufn_DoesTableExist(@in_table_name) = 0
        BEGIN
            PRINT 'Index creation failed: Table ' + @in_table_name + ' does not exist.';
            RETURN;
        END

        -- Check if all columns exist
        IF dbo.ufn_DoColumnsExist(@in_table_name, @in_column_names) = 0
        BEGIN
            PRINT 'Index creation failed: One or more columns in "' + @in_column_names + '" do not exist.';
            RETURN;
        END

        -- Generate a safe index name
        DECLARE @clean_cols NVARCHAR(MAX) = REPLACE(@in_column_names, ',', '_');
        SET @clean_cols = REPLACE(@clean_cols, ' ', '');
        DECLARE @index_name NVARCHAR(255) = N'idx_' + @in_table_name + N'_' + @clean_cols;

        -- Check if index already exists
        IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = @index_name AND object_id = OBJECT_ID(@in_table_name))
        BEGIN
            PRINT 'Index ' + @index_name + ' already exists on table ' + @in_table_name + '.';
            RETURN;
        END

        -- Build and execute the CREATE INDEX statement
        DECLARE @sql NVARCHAR(MAX) = N'CREATE INDEX ' + QUOTENAME(@index_name) + 
                                     N' ON dbo.' + QUOTENAME(@in_table_name) + 
                                     N' (' + @in_column_names + N')';
        EXEC sp_executesql @sql;

        PRINT 'Index ' + @index_name + ' created successfully.';
    END TRY
    BEGIN CATCH
        PRINT 'Index creation failed: ' + ERROR_MESSAGE();
    END CATCH
END
GO

