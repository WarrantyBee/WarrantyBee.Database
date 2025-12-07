CALL usp_ResetAutoIncrement('tblRoles');

INSERT INTO tblRoles (
    name,
    description
)
VALUES
('SUPER_ADMIN', 'Platform-level admin with full system access.'),
('MANUFACTURER', 'Product manufacturer responsible for product data and warranty policies.'),
('VENDOR', 'Authorized vendors or distributors who supply products to retailers.'),
('RETAILER', 'Store owners who sell products directly to customers.'),
('SERVICE_CENTER_MANAGER', 'Manager of an authorized service center handling repairs and claims.'),
('TECHNICIAN', 'Technicians who diagnose and repair electronic products.'),
('CUSTOMER', 'End users who purchase and register products.'),
('SUPPORT_AGENT', 'Customer support personnel handling queries and complaints.'),
('AUDITOR', 'Auditors who review system activities, compliance, and fraud prevention.');

SELECT 'tblRoles data inserted successfully.' AS message;