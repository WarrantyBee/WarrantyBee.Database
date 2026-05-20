IF OBJECT_ID('dbo.usp_CreateColumns_tblPasswordLogs', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_CreateColumns_tblPasswordLogs; GO

CREATE PROCEDURE dbo.usp_CreateColumns_tblPasswordLogs AS
BEGIN
    DECLARE @v_required BIT = 1;
    DECLARE @v_optional BIT = 0;

END
GO

EXEC dbo.usp_CreateColumns_tblPasswordLogs;
IF OBJECT_ID('dbo.usp_CreateColumns_tblPasswordLogs', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_CreateColumns_tblPasswordLogs; GO
