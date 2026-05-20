SET IDENTITY_INSERT tblRolePermissions ON;
GO

MERGE INTO tblRolePermissions AS target
USING (VALUES
    -- CUSTOMER (7) permissions
    (1, 7, 1), -- EDIT_PROFILE
    (2, 7, 2), -- CHANGE_AVATAR
    (3, 7, 3), -- ACCESS_PROFILE
    -- SUPER_ADMIN (1) permissions
    (4, 1, 1),
    (5, 1, 2),
    (6, 1, 3)
) AS source (id, role_id, permission_id)
ON target.id = source.id
WHEN MATCHED THEN
    UPDATE SET 
        role_id = source.role_id,
        permission_id = source.permission_id
WHEN NOT MATCHED THEN
    INSERT (id, role_id, permission_id)
    VALUES (source.id, source.role_id, source.permission_id);
GO

SET IDENTITY_INSERT tblRolePermissions OFF;
GO

DBCC CHECKIDENT ('tblRolePermissions', RESEED, 6);
GO

PRINT N'tblRolePermissions data merged successfully.';
GO
