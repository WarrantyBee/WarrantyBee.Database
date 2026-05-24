SET IDENTITY_INSERT tblRoles ON;
GO

MERGE INTO tblRoles AS target
USING (VALUES
    (1, N'PLATFORM_ADMIN', N'Ultimate platform administrator with access to all tenants and system configurations.'),
    (2, N'PLATFORM_SUPPORT', N'System support and technical auditor for the platform.'),
    (3, N'BUSINESS_OWNER', N'The primary owner of a business tenant.'),
    (4, N'BUSINESS_ADMIN', N'Administrator for a specific business tenant.'),
    (5, N'PLANNER', N'Operations manager focusing on logistics and trends for the brand.'),
    (6, N'BRAND_SUPPORT', N'Frontline support agent for the brand.'),
    (7, N'DISTRIBUTOR', N'Bulk buyer and stock manager for a brand.'),
    (8, N'RETAILER', N'Front-facing seller who activates warranties upon purchase.'),
    (9, N'SERVICE_CENTER_ADMIN', N'Manager of an authorized service center who dispatches technicians.'),
    (10, N'TECHNICIAN', N'Field agent responsible for performing appliance repairs.'),
    (11, N'CUSTOMER', N'End-user who owns products and initiates claims.')
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
