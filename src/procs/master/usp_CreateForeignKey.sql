-- =============================================
-- usp_CreateForeignKey
-- Adds a foreign key constraint between two tables.
--
-- Parameters:
--   @in_table_name      - The child table name.
--   @in_column_name     - The child column name.
--   @in_ref_table_name  - The parent table name.
--   @in_ref_column_name - The parent column name.
-- =============================================

IF OBJECT_ID('dbo.usp_CreateForeignKey', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_CreateForeignKey;
GO

CREATE PROCEDURE dbo.usp_CreateForeignKey
    @in_table_name NVARCHAR(128),
    @in_column_name NVARCHAR(128),
    @in_ref_table_name NVARCHAR(128),
    @in_ref_column_name NVARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Check if tables exist
        IF dbo.ufn_DoesTableExist(@in_table_name) = 0 OR dbo.ufn_DoesTableExist(@in_ref_table_name) = 0
        BEGIN
            PRINT 'FK creation failed: One or both tables (' + @in_table_name + ', ' + @in_ref_table_name + ') do not exist.';
            RETURN;
        END

        -- Generate a safe constraint name
        DECLARE @constraint_name NVARCHAR(255) = N'fk_' + @in_table_name + N'_' + @in_column_name + N'__' + @in_ref_table_name + N'_' + @in_ref_column_name;

        -- Check if FK already exists
        IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = @constraint_name AND parent_object_id = OBJECT_ID(@in_table_name))
        BEGIN
            PRINT 'Foreign Key ' + @constraint_name + ' already exists.';
            RETURN;
        END

        -- Build and execute the ALTER TABLE statement
        DECLARE @sql NVARCHAR(MAX) = N'ALTER TABLE dbo.' + QUOTENAME(@in_table_name) + 
                                     N' ADD CONSTRAINT ' + QUOTENAME(@constraint_name) + 
                                     N' FOREIGN KEY (' + QUOTENAME(@in_column_name) + N')' +
                                     N' REFERENCES dbo.' + QUOTENAME(@in_ref_table_name) + 
                                     N' (' + QUOTENAME(@in_ref_column_name) + N')';
        EXEC sp_executesql @sql;

        PRINT 'Foreign Key ' + @constraint_name + ' created successfully.';
    END TRY
    BEGIN CATCH
        PRINT 'FK creation failed: ' + ERROR_MESSAGE();
    END CATCH
END
GO



