-- =============================================
-- usp_DropConstraint
-- Removes a constraint (PK, FK, UQ, Check) from a table if it exists.
--
-- Parameters:
--   @in_table_name      - The name of the table.
--   @in_constraint_name - The name of the constraint to drop.
-- =============================================

IF OBJECT_ID('dbo.usp_DropConstraint', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_DropConstraint;
GO

CREATE PROCEDURE dbo.usp_DropConstraint
    @in_table_name NVARCHAR(128),
    @in_constraint_name NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Check if table exists
        IF dbo.ufn_DoesTableExist(@in_table_name) = 0
        BEGIN
            PRINT 'Drop constraint failed: Table ' + @in_table_name + ' does not exist.';
            RETURN;
        END

        -- Check if constraint exists in sys.objects (covers PK, FK, UQ, C)
        IF EXISTS (SELECT 1 FROM sys.objects WHERE name = @in_constraint_name AND parent_object_id = OBJECT_ID(@in_table_name))
        BEGIN
            DECLARE @sql NVARCHAR(MAX) = N'ALTER TABLE dbo.' + QUOTENAME(@in_table_name) + 
                                         N' DROP CONSTRAINT ' + QUOTENAME(@in_constraint_name);
            EXEC sp_executesql @sql;

            PRINT 'Constraint ' + @in_constraint_name + ' dropped successfully from table ' + @in_table_name + '.';
        END
        ELSE
        BEGIN
            PRINT 'Constraint ' + @in_constraint_name + ' does not exist on table ' + @in_table_name + '.';
        END
    END TRY
    BEGIN CATCH
        PRINT 'Drop constraint failed: ' + ERROR_MESSAGE();
    END CATCH
END
GO


