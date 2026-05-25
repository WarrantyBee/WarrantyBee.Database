IF OBJECT_ID('dbo.usp_CreateColumns_tblMigrationHistory', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_CreateColumns_tblMigrationHistory;
GO

CREATE PROCEDURE dbo.usp_CreateColumns_tblMigrationHistory AS
BEGIN
    DECLARE @v_required BIT = 1;
    DECLARE @v_optional BIT = 0;

    EXEC dbo.usp_AddColumn N'tblMigrationHistory', 'script_name', 'VARCHAR(255)', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblMigrationHistory', 'applied_at', 'DATETIME2', 'GETUTCDATE()', @v_required;
    EXEC dbo.usp_AddColumn N'tblMigrationHistory', 'execution_time_ms', 'INT', '0', @v_required;
END
GO

EXEC dbo.usp_CreateColumns_tblMigrationHistory;
GO
