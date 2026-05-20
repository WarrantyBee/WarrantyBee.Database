IF OBJECT_ID('dbo.usp_CreateColumns_tblRolePermissions', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_CreateColumns_tblRolePermissions; GO

CREATE PROCEDURE dbo.usp_CreateColumns_tblRolePermissions AS
BEGIN
    DECLARE @v_required BIT = 1;
    DECLARE @v_optional BIT = 0;

END
GO

EXEC dbo.usp_CreateColumns_tblRolePermissions;
IF OBJECT_ID('dbo.usp_CreateColumns_tblRolePermissions', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_CreateColumns_tblRolePermissions; GO
