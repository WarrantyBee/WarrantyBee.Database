IF OBJECT_ID('dbo.usp_CreateColumns_tblLanguages', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_CreateColumns_tblLanguages; GO

CREATE PROCEDURE dbo.usp_CreateColumns_tblLanguages AS
BEGIN
    DECLARE @v_required BIT = 1;
    DECLARE @v_optional BIT = 0;

END
GO

EXEC dbo.usp_CreateColumns_tblLanguages;
IF OBJECT_ID('dbo.usp_CreateColumns_tblLanguages', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_CreateColumns_tblLanguages; GO
