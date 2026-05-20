-- =============================================
-- usp_CreateTable
-- Creates a table with columns 'id', 'created_by', 'updated_by', 'created_at', 'updated_at', and 'void'
-- if it does not already exist, and adds a primary key constraint.
--
-- Parameters:
--   @in_table_name - The name of the table to create.
-- =============================================

IF OBJECT_ID('dbo.usp_CreateTable', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_CreateTable;
GO

CREATE PROCEDURE dbo.usp_CreateTable
    @in_table_name NVARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Check if table already exists
        IF dbo.ufn_DoesTableExist(@in_table_name) = 1
        BEGIN
            PRINT 'Table ' + @in_table_name + ' already exists.';
            RETURN;
        END

        -- Create table with 'id' as identity column immediately (SQL Server best practice)
        DECLARE @sql NVARCHAR(MAX) = N'CREATE TABLE dbo.' + QUOTENAME(@in_table_name) + N' (id BIGINT IDENTITY(1,1) NOT NULL)';
        EXEC sp_executesql @sql;

        -- Add primary key constraint on 'id'
        DECLARE @pk_name NVARCHAR(255) = N'pk_' + @in_table_name + N'_id';
        EXEC dbo.usp_CreatePrimaryKey @in_table_name, N'id', @pk_name;

        -- Add standard columns using usp_AddColumn
        EXEC dbo.usp_AddColumn @in_table_name, N'internal_id', N'BINARY(16)', NULL, 1;
        EXEC dbo.usp_AddColumn @in_table_name, N'created_by', N'BIGINT', NULL, 1;
        EXEC dbo.usp_AddColumn @in_table_name, N'updated_by', N'BIGINT', NULL, 0;
        EXEC dbo.usp_AddColumn @in_table_name, N'created_at', N'DATETIME2', N'GETUTCDATE()', 1;
        EXEC dbo.usp_AddColumn @in_table_name, N'updated_at', N'DATETIME2', NULL, 0;
        EXEC dbo.usp_AddColumn @in_table_name, N'void', N'BIT', N'0', 0;

        -- Add unique key constraint on 'internal_id'
        EXEC dbo.usp_CreateUniqueKey @in_table_name, N'internal_id';

        -- Add update trigger for 'updated_at'
        EXEC dbo.usp_CreateUpdateTrigger @in_table_name;

        PRINT 'Table ' + @in_table_name + ' created successfully.';
    END TRY
    BEGIN CATCH
        PRINT 'Table ' + @in_table_name + ' creation failed: ' + ERROR_MESSAGE();
    END CATCH
END
GO

