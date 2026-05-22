IF OBJECT_ID('dbo.usp_CreateColumns_tblEventLogs', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_CreateColumns_tblEventLogs; GO

CREATE PROCEDURE dbo.usp_CreateColumns_tblEventLogs AS
BEGIN
    DECLARE @v_required BIT = 1;
    DECLARE @v_optional BIT = 0;

    EXEC dbo.usp_AddColumn N'tblEventLogs', 'event_type', 'VARCHAR(100)', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblEventLogs', 'payload', 'NVARCHAR(MAX)', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblEventLogs', 'status', 'VARCHAR(50)', N'''PENDING''', @v_required;
    
    EXEC dbo.usp_DropColumn N'tblEventLogs', 'created_by';
    EXEC dbo.usp_DropColumn N'tblEventLogs', 'updated_by';
END
GO

EXEC dbo.usp_CreateColumns_tblEventLogs;
IF OBJECT_ID('dbo.usp_CreateColumns_tblEventLogs', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_CreateColumns_tblEventLogs; GO
