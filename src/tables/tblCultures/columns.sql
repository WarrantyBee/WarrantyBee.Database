IF OBJECT_ID('dbo.usp_CreateColumns_tblCultures', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_CreateColumns_tblCultures; GO

CREATE PROCEDURE dbo.usp_CreateColumns_tblCultures AS
BEGIN
    DECLARE @v_required BIT = 1;
    DECLARE @v_optional BIT = 0;

END
GO

EXEC dbo.usp_CreateColumns_tblCultures;
IF OBJECT_ID('dbo.usp_CreateColumns_tblCultures', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_CreateColumns_tblCultures; GO
