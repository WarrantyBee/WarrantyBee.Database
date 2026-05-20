SET IDENTITY_INSERT tblPermissions ON;
GO

MERGE INTO tblPermissions AS target
USING (VALUES
    (1, N'EDIT_PROFILE', N'Allows an user to edit their personal profile details.'),
    (2, N'CHANGE_AVATAR', N'Allows a user to change their profile avatar.'),
    (3, N'ACCESS_PROFILE', N'Allows users to access their profile.')
) AS source (id, name, description)
ON target.id = source.id
WHEN MATCHED THEN
    UPDATE SET name = source.name, description = source.description
WHEN NOT MATCHED THEN
    INSERT (id, name, description)
    VALUES (source.id, source.name, source.description);
GO

SET IDENTITY_INSERT tblPermissions OFF;
GO

DBCC CHECKIDENT ('tblPermissions', RESEED, 3);
GO

PRINT N'tblPermissions data merged successfully.';
GO
