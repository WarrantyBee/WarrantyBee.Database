-- =============================================
-- usp_CreateUpdateTrigger
-- Creates an AFTER UPDATE trigger on a table to automatically set the 'updated_at' column to current UTC time.
--
-- Parameters:
--   @in_table_name - The name of the table to add the trigger to.
-- =============================================

IF OBJECT_ID('dbo.usp_CreateUpdateTrigger', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_CreateUpdateTrigger;
GO

CREATE PROCEDURE dbo.usp_CreateUpdateTrigger
    @in_table_name NVARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Check if table exists
        IF dbo.ufn_DoesTableExist(@in_table_name) = 0
        BEGIN
            PRINT 'Trigger creation failed: Table ' + @in_table_name + ' does not exist.';
            RETURN;
        END

        -- Generate trigger name
        DECLARE @trigger_name NVARCHAR(255) = N'trg_AfterUpdate_' + @in_table_name;

        -- Check if trigger already exists
        IF EXISTS (SELECT 1 FROM sys.triggers WHERE name = @trigger_name AND parent_id = OBJECT_ID(@in_table_name))
        BEGIN
            PRINT 'Trigger ' + @trigger_name + ' already exists.';
            RETURN;
        END

        -- Build dynamic SQL for trigger creation
        -- We use a batch-compatible format
        DECLARE @sql NVARCHAR(MAX) = 
            N'CREATE TRIGGER ' + QUOTENAME(@trigger_name) + N' ' +
            N'ON dbo.' + QUOTENAME(@in_table_name) + N' ' +
            N'AFTER UPDATE ' +
            N'AS ' +
            N'BEGIN ' +
            N'    SET NOCOUNT ON; ' +
            N'    UPDATE dbo.' + QUOTENAME(@in_table_name) + N' ' +
            N'    SET updated_at = GETUTCDATE() ' +
            N'    FROM dbo.' + QUOTENAME(@in_table_name) + N' t ' +
            N'    JOIN inserted i ON t.id = i.id; ' +
            N'END;';

        EXEC sp_executesql @sql;

        PRINT 'Trigger ' + @trigger_name + ' created successfully on table ' + @in_table_name + '.';
    END TRY
    BEGIN CATCH
        PRINT 'Trigger creation failed for table ' + @in_table_name + ': ' + ERROR_MESSAGE();
    END CATCH
END
GO


