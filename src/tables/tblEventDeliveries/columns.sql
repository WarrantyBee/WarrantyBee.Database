IF OBJECT_ID('dbo.usp_CreateColumns_tblEventDeliveries', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_CreateColumns_tblEventDeliveries; GO

CREATE PROCEDURE dbo.usp_CreateColumns_tblEventDeliveries AS
BEGIN
    DECLARE @v_required BIT = 1;
    DECLARE @v_optional BIT = 0;

    EXEC dbo.usp_AddColumn N'tblEventDeliveries', 'event_log_id', 'BIGINT', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblEventDeliveries', 'subscription_id', 'BIGINT', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblEventDeliveries', 'response_status_code', 'INT', NULL, @v_optional;
    EXEC dbo.usp_AddColumn N'tblEventDeliveries', 'response_body', 'NVARCHAR(MAX)', NULL, @v_optional;
    EXEC dbo.usp_AddColumn N'tblEventDeliveries', 'attempt_count', 'INT', '1', @v_required;
    
    EXEC dbo.usp_DropColumn N'tblEventDeliveries', 'created_by';
    EXEC dbo.usp_DropColumn N'tblEventDeliveries', 'updated_by';
END
GO

EXEC dbo.usp_CreateColumns_tblEventDeliveries;
IF OBJECT_ID('dbo.usp_CreateColumns_tblEventDeliveries', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_CreateColumns_tblEventDeliveries; GO
