SET IDENTITY_INSERT tblRoles ON;
GO

MERGE INTO tblRoles AS target
USING (VALUES
    (1, N'PlatformAdmin', N'Ultimate platform administrator with access to all tenants and system configurations.'),
    (2, N'PlatformSupport', N'System support and technical auditor for the platform.'),
    (3, N'BusinessOwner', N'The primary owner of a business tenant.'),
    (4, N'BusinessAdmin', N'Administrator for a specific business tenant.'),
    (5, N'Planner', N'Operations manager focusing on logistics and trends for the brand.'),
    (6, N'BrandSupport', N'Frontline support agent for the brand.'),
    (7, N'Distributor', N'Bulk buyer and stock manager for a brand.'),
    (8, N'Retailer', N'Front-facing seller who activates warranties upon purchase.'),
    (9, N'ServiceCenterAdmin', N'Manager of an authorized service center who dispatches technicians.'),
    (10, N'Technician', N'Field agent responsible for performing appliance repairs.'),
    (11, N'Customer', N'End-user who owns products and initiates claims.')
) AS source (id, name, description)
ON target.id = source.id
WHEN MATCHED THEN
    UPDATE SET name = source.name, description = source.description
WHEN NOT MATCHED THEN
    INSERT (id, name, description)
    VALUES (source.id, source.name, source.description);
GO

SET IDENTITY_INSERT tblRoles OFF;
GO

DBCC CHECKIDENT ('tblRoles', RESEED, 11);
GO

PRINT N'tblRoles data merged successfully.';
GO
