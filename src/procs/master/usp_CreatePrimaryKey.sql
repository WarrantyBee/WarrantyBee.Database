-- =============================================
-- usp_CreatePrimaryKey
-- Adds a primary key constraint to a table.
--
-- Parameters:
--   @in_table_name   - The name of the table.
--   @in_column_name  - The column to set as the primary key.
--   @in_constraint_name - The name of the primary key constraint.
-- =============================================

IF OBJECT_ID('dbo.usp_CreatePrimaryKey', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_CreatePrimaryKey;
GO

CREATE PROCEDURE dbo.usp_CreatePrimaryKey
    @in_table_name NVARCHAR(128),
    @in_column_name NVARCHAR(128),
    @in_constraint_name NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Check if table exists
        IF dbo.ufn_DoesTableExist(@in_table_name) = 0
        BEGIN
            PRINT 'PK creation failed: Table ' + @in_table_name + ' does not exist.';
            RETURN;
        END

        -- Check if PK already exists
        IF EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID(@in_table_name) AND type = 'PK')
        BEGIN
            PRINT 'Primary Key already exists for table ' + @in_table_name + '.';
            RETURN;
        END

        DECLARE @sql NVARCHAR(MAX) = N'ALTER TABLE dbo.' + QUOTENAME(@in_table_name) + 
                                     N' ADD CONSTRAINT ' + QUOTENAME(@in_constraint_name) + 
                                     N' PRIMARY KEY (' + QUOTENAME(@in_column_name) + N')';
        EXEC sp_executesql @sql;

        PRINT 'Primary Key ' + @in_constraint_name + ' created successfully.';
    END TRY
    BEGIN CATCH
        PRINT 'PK creation failed: ' + ERROR_MESSAGE();
    END CATCH
END
GO


