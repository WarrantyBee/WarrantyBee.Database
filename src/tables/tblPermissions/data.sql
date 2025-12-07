CALL usp_ResetAutoIncrement('tblPermissions');

INSERT INTO tblPermissions (
    name,
    description
)
VALUES
('EDIT_PROFILE', 'Allows an user to edit their personal profile details.'),
('CHANGE_AVATAR', 'Allows a user to change their profile avatar.'),
('ACCESS_PROFILE', 'Allows users to access their profile.');

SELECT 'tblPermissions data inserted successfully.' AS message;
