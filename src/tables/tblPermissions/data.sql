EXEC dbo.usp_ResetAutoIncrement N'tblPermissions';
GO

INSERT INTO tblPermissions (
    name,
    description
)
VALUES
(N'EDIT_PROFILE', N'Allows an user to edit their personal profile details.'),
(N'CHANGE_AVATAR', N'Allows a user to change their profile avatar.'),
(N'ACCESS_PROFILE', N'Allows users to access their profile.');

PRINT N'tblPermissions data inserted successfully.';
GO
