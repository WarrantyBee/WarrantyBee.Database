-- =============================================
-- usp_AddCheck
-- Adds a check constraint to a table.
--
-- Parameters:
--   @in_table_name      - The name of the table.
--   @in_constraint_name - The name of the check constraint.
--   @in_condition      - The logical condition for the check constraint.
-- =============================================

IF OBJECT_ID('dbo.usp_AddCheck', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_AddCheck;
GO

CREATE PROCEDURE dbo.usp_AddCheck
    @in_table_name NVARCHAR(128),
    @in_constraint_name NVARCHAR(255),
    @in_condition NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Check if table exists
        IF dbo.ufn_DoesTableExist(@in_table_name) = 0
        BEGIN
            PRINT 'Check constraint creation failed: Table ' + @in_table_name + ' does not exist.';
            RETURN;
        END

        -- Check if constraint already exists
        IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = @in_constraint_name AND parent_object_id = OBJECT_ID(@in_table_name))
        BEGIN
            PRINT 'Check constraint ' + @in_constraint_name + ' already exists.';
            RETURN;
        END

        DECLARE @sql NVARCHAR(MAX) = N'ALTER TABLE dbo.' + QUOTENAME(@in_table_name) + 
                                     N' ADD CONSTRAINT ' + QUOTENAME(@in_constraint_name) + 
                                     N' CHECK (' + @in_condition + N')';
        EXEC sp_executesql @sql;

        PRINT 'Check constraint ' + @in_constraint_name + ' created successfully.';
    END TRY
    BEGIN CATCH
        PRINT 'Check constraint creation failed: ' + ERROR_MESSAGE();
    END CATCH
END
GO

