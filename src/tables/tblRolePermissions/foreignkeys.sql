EXEC dbo.usp_CreateForeignKey N'tblRolePermissions', N'role_id', N'tblRoles', N'id';
EXEC dbo.usp_CreateForeignKey N'tblRolePermissions', N'permission_id', N'tblPermissions', N'id';

