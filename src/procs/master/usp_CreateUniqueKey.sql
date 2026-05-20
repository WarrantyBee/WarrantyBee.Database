-- =============================================
-- usp_CreateUniqueKey
-- Adds a unique constraint (via a filtered unique index) to a column in a table.
-- This allows multiple NULL values while enforcing uniqueness for non-NULL values,
-- which matches MySQL's UNIQUE behavior.
--
-- Parameters:
--   @in_table_name   - The name of the table.
--   @in_column_name  - The name of the column (or comma-separated columns).
-- =============================================

IF OBJECT_ID('dbo.usp_CreateUniqueKey', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_CreateUniqueKey;
GO

CREATE PROCEDURE dbo.usp_CreateUniqueKey
    @in_table_name NVARCHAR(128),
    @in_column_name NVARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Check if table exists
        IF dbo.ufn_DoesTableExist(@in_table_name) = 0
        BEGIN
            PRINT 'Unique key creation failed: Table ' + @in_table_name + ' does not exist.';
            RETURN;
        END

        -- Generate a safe index name
        DECLARE @clean_cols NVARCHAR(MAX) = REPLACE(@in_column_name, ',', '_');
        SET @clean_cols = REPLACE(@clean_cols, ' ', '');
        DECLARE @index_name NVARCHAR(255) = N'uq_' + @in_table_name + N'_' + @clean_cols;

        -- Check if unique index already exists
        IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = @index_name AND object_id = OBJECT_ID(@in_table_name))
        BEGIN
            PRINT 'Unique index ' + @index_name + ' already exists.';
            RETURN;
        END

        -- Build a filtered unique index statement
        -- This is the T-SQL equivalent of MySQL's UNIQUE which allows multiple NULLs.
        -- We'll apply the filter to the first column if it's a composite key, or the single column.
        -- For simplicity in this helper, we'll just check if it's a single column for the filter.
        
        DECLARE @sql NVARCHAR(MAX);
        IF CHARINDEX(',', @in_column_name) = 0
        BEGIN
            SET @sql = N'CREATE UNIQUE INDEX ' + QUOTENAME(@index_name) + 
                       N' ON dbo.' + QUOTENAME(@in_table_name) + 
                       N' (' + QUOTENAME(@in_column_name) + N') ' +
                       N' WHERE ' + QUOTENAME(@in_column_name) + N' IS NOT NULL';
        END
        ELSE
        BEGIN
            -- For composite keys, the filter logic is more complex. We'll just do a standard unique index.
            SET @sql = N'CREATE UNIQUE INDEX ' + QUOTENAME(@index_name) + 
                       N' ON dbo.' + QUOTENAME(@in_table_name) + 
                       N' (' + @in_column_name + N')';
        END

        EXEC sp_executesql @sql;

        PRINT 'Unique index ' + @index_name + ' created successfully.';
    END TRY
    BEGIN CATCH
        PRINT 'Unique key creation failed: ' + ERROR_MESSAGE();
    END CATCH
END
GO


