IF OBJECT_ID('dbo.usp_CreateColumns_tblRolePermissions', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_CreateColumns_tblRolePermissions; GO

CREATE PROCEDURE dbo.usp_CreateColumns_tblRolePermissions AS
BEGIN
    DECLARE @v_required BIT = 1;
    DECLARE @v_optional BIT = 0;

    EXEC dbo.usp_AddColumn N'tblRolePermissions', 'role_id', 'BIGINT', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblRolePermissions', 'permission_id', 'BIGINT', NULL, @v_required;

    EXEC dbo.usp_DropColumn N'tblRolePermissions', 'created_by';
    EXEC dbo.usp_DropColumn N'tblRolePermissions', 'updated_by';
END
GO

EXEC dbo.usp_CreateColumns_tblRolePermissions;
IF OBJECT_ID('dbo.usp_CreateColumns_tblRolePermissions', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_CreateColumns_tblRolePermissions; GO

