SET IDENTITY_INSERT tblRoles ON;
GO

MERGE INTO tblRoles AS target
USING (VALUES
    (1, N'SUPER_ADMIN', N'Platform-level admin with full system access.'),
    (2, N'MANUFACTURER', N'Product manufacturer responsible for product data and warranty policies.'),
    (3, N'VENDOR', N'Authorized vendors or distributors who supply products to retailers.'),
    (4, N'RETAILER', N'Store owners who sell products directly to customers.'),
    (5, N'SERVICE_CENTER_MANAGER', N'Manager of an authorized service center handling repairs and claims.'),
    (6, N'TECHNICIAN', N'Technicians who diagnose and repair electronic products.'),
    (7, N'CUSTOMER', N'End users who purchase and register products.'),
    (8, N'SUPPORT_AGENT', N'Customer support personnel handling queries and complaints.'),
    (9, N'AUDITOR', N'Auditors who review system activities, compliance, and fraud prevention.')
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

DBCC CHECKIDENT ('tblRoles', RESEED, 9);
GO

PRINT N'tblRoles data merged successfully.';
GO
