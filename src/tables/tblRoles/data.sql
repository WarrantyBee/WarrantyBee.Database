EXEC dbo.usp_ResetAutoIncrement N'tblRoles';
GO

INSERT INTO tblRoles (
    name,
    description
)
VALUES
(N'SUPER_ADMIN', N'Platform-level admin with full system access.'),
(N'MANUFACTURER', N'Product manufacturer responsible for product data and warranty policies.'),
(N'VENDOR', N'Authorized vendors or distributors who supply products to retailers.'),
(N'RETAILER', N'Store owners who sell products directly to customers.'),
(N'SERVICE_CENTER_MANAGER', N'Manager of an authorized service center handling repairs and claims.'),
(N'TECHNICIAN', N'Technicians who diagnose and repair electronic products.'),
(N'CUSTOMER', N'End users who purchase and register products.'),
(N'SUPPORT_AGENT', N'Customer support personnel handling queries and complaints.'),
(N'AUDITOR', N'Auditors who review system activities, compliance, and fraud prevention.');

PRINT N'tblRoles data inserted successfully.';
GO