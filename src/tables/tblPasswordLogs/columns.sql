IF OBJECT_ID('dbo.usp_CreateColumns_tblPasswordLogs', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_CreateColumns_tblPasswordLogs; GO

CREATE PROCEDURE dbo.usp_CreateColumns_tblPasswordLogs AS
BEGIN
    DECLARE @v_required BIT = 1;
    DECLARE @v_optional BIT = 0;

    EXEC dbo.usp_AddColumn N'tblPasswordLogs', 'user_id', 'BIGINT', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblPasswordLogs', 'password', 'VARCHAR(1024)', NULL, @v_required;

    EXEC dbo.usp_DropColumn N'tblPasswordLogs', 'created_by';
    EXEC dbo.usp_DropColumn N'tblPasswordLogs', 'updated_by';
END
GO

EXEC dbo.usp_CreateColumns_tblPasswordLogs;
IF OBJECT_ID('dbo.usp_CreateColumns_tblPasswordLogs', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_CreateColumns_tblPasswordLogs; GO

