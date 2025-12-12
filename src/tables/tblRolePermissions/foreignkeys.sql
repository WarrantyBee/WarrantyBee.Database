CALL usp_CreateForeignKey('tblRolePermissions', 'role_id', 'tblRoles', 'id');
CALL usp_CreateForeignKey('tblRolePermissions', 'permission_id', 'tblPermissions', 'id');