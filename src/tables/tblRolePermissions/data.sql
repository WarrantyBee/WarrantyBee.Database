EXEC dbo.usp_ResetAutoIncrement N'tblRolePermissions';
GO

INSERT INTO tblRolePermissions (
    role_id,
    permission_id
)
VALUES
(7, 1),
(7, 2),
(7, 3);

PRINT N'tblRolePermissions data inserted successfully.';
GO
