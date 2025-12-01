CALL usp_ResetAutoIncrement('tblPermissions');

INSERT INTO tblPermissions (
    name,
    description
)
VALUES
('EDIT_PROFILE', 'Allows an user to edit their personal profile details.'),
('REGISTER_PRODUCT', 'Allows an user to register a newly purchased product in the system.'),
('REGISTER_WARRANTY', 'Allows an user to upload invoice/warranty documents and activate warranty coverage.');

SELECT 'tblPermissions data inserted successfully.' AS message;
