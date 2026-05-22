IF OBJECT_ID('dbo.usp_CreateColumns_tblNotifications', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_CreateColumns_tblNotifications; GO

CREATE PROCEDURE dbo.usp_CreateColumns_tblNotifications AS
BEGIN
    DECLARE @v_required BIT = 1;
    DECLARE @v_optional BIT = 0;

    EXEC dbo.usp_AddColumn N'tblNotifications', 'user_id', 'BIGINT', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblNotifications', 'title', 'NVARCHAR(255)', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblNotifications', 'message', 'NVARCHAR(MAX)', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblNotifications', 'is_read', 'BIT', '0', @v_required;
    EXEC dbo.usp_AddColumn N'tblNotifications', 'type', 'VARCHAR(50)', NULL, @v_required;
    
    EXEC dbo.usp_DropColumn N'tblNotifications', 'created_by';
    EXEC dbo.usp_DropColumn N'tblNotifications', 'updated_by';
END
GO

EXEC dbo.usp_CreateColumns_tblNotifications;
IF OBJECT_ID('dbo.usp_CreateColumns_tblNotifications', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_CreateColumns_tblNotifications; GO
