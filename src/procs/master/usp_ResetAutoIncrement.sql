-- =============================================
-- usp_ResetAutoIncrement
-- Resets the seed value for an IDENTITY column.
--
-- Parameters:
--   @in_table_name - The name of the table to reset.
-- =============================================

IF OBJECT_ID('dbo.usp_ResetAutoIncrement', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_ResetAutoIncrement;
GO

CREATE PROCEDURE dbo.usp_ResetAutoIncrement
    @in_table_name NVARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Check if table exists
        IF dbo.ufn_DoesTableExist(@in_table_name) = 0
        BEGIN
            PRINT 'Reset identity failed: Table ' + @in_table_name + ' does not exist.';
            RETURN;
        END

        -- Reset identity seed to 0 (so next value is 1)
        -- SQL Server syntax: DBCC CHECKIDENT ('table', RESEED, 0)
        -- Note: If table is not empty, this might cause collisions.
        DECLARE @sql NVARCHAR(MAX) = N'DBCC CHECKIDENT (''' + REPLACE(@in_table_name, '''', '''''') + N''', RESEED, 0)';
        EXEC sp_executesql @sql;

        PRINT 'Identity seed for table ' + @in_table_name + ' reset successfully.';
    END TRY
    BEGIN CATCH
        PRINT 'Reset identity failed: ' + ERROR_MESSAGE();
    END CATCH
END
GO

