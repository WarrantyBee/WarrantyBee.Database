IF OBJECT_ID('dbo.usp_CreateColumns_tblPermissions', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_CreateColumns_tblPermissions; GO

CREATE PROCEDURE dbo.usp_CreateColumns_tblPermissions AS
BEGIN
    DECLARE @v_required BIT = 1;
    DECLARE @v_optional BIT = 0;

END
GO

EXEC dbo.usp_CreateColumns_tblPermissions;
IF OBJECT_ID('dbo.usp_CreateColumns_tblPermissions', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_CreateColumns_tblPermissions; GO
