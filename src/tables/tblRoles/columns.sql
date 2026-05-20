IF OBJECT_ID('dbo.usp_CreateColumns_tblRoles', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_CreateColumns_tblRoles; GO

CREATE PROCEDURE dbo.usp_CreateColumns_tblRoles AS
BEGIN
    DECLARE @v_required BIT = 1;
    DECLARE @v_optional BIT = 0;

END
GO

EXEC dbo.usp_CreateColumns_tblRoles;
IF OBJECT_ID('dbo.usp_CreateColumns_tblRoles', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_CreateColumns_tblRoles; GO
