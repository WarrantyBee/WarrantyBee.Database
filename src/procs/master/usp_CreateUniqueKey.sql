-- =============================================
-- usp_CreateUniqueKey
-- Adds a unique constraint to a column in a table.
--
-- Parameters:
--   @in_table_name   - The name of the table.
--   @in_column_name  - The name of the column.
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

        DECLARE @constraint_name NVARCHAR(255) = N'uq_' + @in_table_name + N'_' + @in_column_name;

        -- Check if unique constraint already exists
        IF EXISTS (SELECT 1 FROM sys.objects WHERE name = @constraint_name AND type = 'UQ')
        BEGIN
            PRINT 'Unique key ' + @constraint_name + ' already exists.';
            RETURN;
        END

        DECLARE @sql NVARCHAR(MAX) = N'ALTER TABLE dbo.' + QUOTENAME(@in_table_name) + 
                                     N' ADD CONSTRAINT ' + QUOTENAME(@constraint_name) + 
                                     N' UNIQUE (' + QUOTENAME(@in_column_name) + N')';
        EXEC sp_executesql @sql;

        PRINT 'Unique key ' + @constraint_name + ' created successfully.';
    END TRY
    BEGIN CATCH
        PRINT 'Unique key creation failed: ' + ERROR_MESSAGE();
    END CATCH
END
GO

