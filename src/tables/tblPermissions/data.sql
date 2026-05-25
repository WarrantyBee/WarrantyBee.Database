SET IDENTITY_INSERT tblPermissions ON;
GO

MERGE INTO tblPermissions AS target
USING (VALUES
    (1, N'EditProfile', N'Allows a user to edit their personal profile details.'),
    (2, N'ChangeAvatar', N'Allows a user to change their profile avatar.'),
    (3, N'AccessProfile', N'Allows users to access their profile.'),
    (10, N'ManagePlatform', N'Full management of the platform and tenants.'),
    (11, N'AuditSystem', N'Technical auditing and log access.'),
    (12, N'OnboardBusiness', N'Generate secure onboarding links for new businesses.'),
    (20, N'ManageBusinessProfile', N'Manage the business''s public profile and branding.'),
    (21, N'ManageBusinessUsers', N'Manage users within a specific business tenant.'),
    (22, N'InviteStaff', N'Generate invitation links for internal staff.'),
    (23, N'ManageProducts', N'Manage the product catalog and warranty policies.'),
    (24, N'ManageLogistics', N'Analyze trends and manage spare parts inventory.'),
    (30, N'ApproveClaims', N'Final approval or rejection of high-value warranty claims.'),
    (31, N'AssignTickets', N'Dispatch tickets to service centers and technicians.'),
    (32, N'UpdateTickets', N'Update ticket status and repair progress.'),
    (33, N'SubmitClaims', N'Initiate a new warranty claim.'),
    (40, N'ActivateWarranty', N'Activate a product warranty at the point of sale.'),
    (41, N'ManageInventory', N'Manage batch transfers and stock allocations.')
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
