IF OBJECT_ID('dbo.usp_CreateColumns_tblEventSubscriptions', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_CreateColumns_tblEventSubscriptions; GO

CREATE PROCEDURE dbo.usp_CreateColumns_tblEventSubscriptions AS
BEGIN
    DECLARE @v_required BIT = 1;
    DECLARE @v_optional BIT = 0;

    EXEC dbo.usp_AddColumn N'tblEventSubscriptions', 'user_id', 'BIGINT', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblEventSubscriptions', 'event_type', 'VARCHAR(100)', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblEventSubscriptions', 'webhook_url', 'VARCHAR(2048)', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblEventSubscriptions', 'secret_key', 'VARCHAR(255)', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblEventSubscriptions', 'is_active', 'BIT', '1', @v_required;
    
    EXEC dbo.usp_DropColumn N'tblEventSubscriptions', 'created_by';
    EXEC dbo.usp_DropColumn N'tblEventSubscriptions', 'updated_by';
END
GO

EXEC dbo.usp_CreateColumns_tblEventSubscriptions;
IF OBJECT_ID('dbo.usp_CreateColumns_tblEventSubscriptions', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_CreateColumns_tblEventSubscriptions; GO
