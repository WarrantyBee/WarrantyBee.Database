SET IDENTITY_INSERT tblPermissions ON;
GO

MERGE INTO tblPermissions AS target
USING (VALUES
    (1, N'EDIT_PROFILE', N'Allows a user to edit their personal profile details.'),
    (2, N'CHANGE_AVATAR', N'Allows a user to change their profile avatar.'),
    (3, N'ACCESS_PROFILE', N'Allows users to access their profile.'),
    (10, N'MANAGE_PLATFORM', N'Full management of the platform and tenants.'),
    (11, N'AUDIT_SYSTEM', N'Technical auditing and log access.'),
    (20, N'MANAGE_BUSINESS_USERS', N'Manage users within a specific business tenant.'),
    (21, N'MANAGE_PRODUCTS', N'Manage the product catalog and warranty policies.'),
    (22, N'MANAGE_LOGISTICS', N'Analyze trends and manage spare parts inventory.'),
    (30, N'APPROVE_CLAIMS', N'Final approval or rejection of high-value warranty claims.'),
    (31, N'ASSIGN_TICKETS', N'Dispatch tickets to service centers and technicians.'),
    (32, N'UPDATE_TICKETS', N'Update ticket status and repair progress.'),
    (33, N'SUBMIT_CLAIMS', N'Initiate a new warranty claim.'),
    (40, N'ACTIVATE_WARRANTY', N'Activate a product warranty at the point of sale.'),
    (41, N'MANAGE_INVENTORY', N'Manage batch transfers and stock allocations.')
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

DBCC CHECKIDENT ('tblPermissions', RESEED, 41);
GO

PRINT N'tblPermissions data merged successfully.';
GO
