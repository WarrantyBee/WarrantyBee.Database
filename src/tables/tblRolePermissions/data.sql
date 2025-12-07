CALL usp_ResetAutoIncrement('tblRolePermissions');

INSERT INTO tblRolePermissions (
    role_id,
    permission_id
)
VALUES
(7, 1),
(7, 2),
(7, 3);

SELECT 'tblRolePermissions data inserted successfully.' AS message;
