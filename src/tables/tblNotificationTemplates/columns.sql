IF OBJECT_ID('dbo.usp_CreateColumns_tblNotificationTemplates', 'P') IS NOT NULL 
    DROP PROCEDURE dbo.usp_CreateColumns_tblNotificationTemplates; 
GO

CREATE PROCEDURE dbo.usp_CreateColumns_tblNotificationTemplates AS
BEGIN
    DECLARE @v_required BIT = 1;
    DECLARE @v_optional BIT = 0;

    EXEC dbo.usp_AddColumn N'tblNotificationTemplates', 'name', 'VARCHAR(128)', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblNotificationTemplates', 'subject', 'NVARCHAR(256)', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblNotificationTemplates', 'body_html', 'NVARCHAR(MAX)', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblNotificationTemplates', 'type', 'VARCHAR(50)', N'''EMAIL''', @v_required;
    
    EXEC dbo.usp_DropColumn N'tblNotificationTemplates', 'created_by';
    EXEC dbo.usp_DropColumn N'tblNotificationTemplates', 'updated_by';
END
GO

EXEC dbo.usp_CreateColumns_tblNotificationTemplates;
GO

IF OBJECT_ID('dbo.usp_CreateColumns_tblNotificationTemplates', 'P') IS NOT NULL 
    DROP PROCEDURE dbo.usp_CreateColumns_tblNotificationTemplates; 
GO
