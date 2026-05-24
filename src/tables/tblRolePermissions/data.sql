SET IDENTITY_INSERT tblRolePermissions ON;
GO

MERGE INTO tblRolePermissions AS target
USING (VALUES
    -- CUSTOMER (11) permissions
    (1, 11, 1), -- EDIT_PROFILE
    (2, 11, 2), -- CHANGE_AVATAR
    (3, 11, 3), -- ACCESS_PROFILE
    (4, 11, 33), -- SUBMIT_CLAIMS
    
    -- PLATFORM_ADMIN (1) permissions
    (5, 1, 1),
    (6, 1, 2),
    (7, 1, 3),
    (8, 1, 10), -- MANAGE_PLATFORM
    (9, 1, 11), -- AUDIT_SYSTEM
    (46, 1, 12), -- ONBOARD_BUSINESS
    
    -- BUSINESS_OWNER (3) permissions
    (10, 3, 1), (11, 3, 2), (12, 3, 3),
    (13, 3, 20), -- MANAGE_BUSINESS_PROFILE
    (14, 3, 21), -- MANAGE_BUSINESS_USERS
    (47, 3, 22), -- INVITE_STAFF
    (48, 3, 23), -- MANAGE_PRODUCTS
    (15, 3, 30), -- APPROVE_CLAIMS
    
    -- BUSINESS_ADMIN (4)
    (16, 4, 1), (17, 4, 2), (18, 4, 3),
    (19, 4, 21), -- MANAGE_BUSINESS_USERS
    (49, 4, 22), -- INVITE_STAFF
    (50, 4, 23), -- MANAGE_PRODUCTS
    (20, 4, 30), -- APPROVE_CLAIMS
    
    -- PLANNER (5)
    (21, 5, 1), (22, 5, 2), (23, 5, 3),
    (24, 5, 22), -- MANAGE_LOGISTICS
    
    -- BRAND_SUPPORT (6)
    (25, 6, 1), (26, 6, 2), (27, 6, 3),
    (28, 6, 31), -- ASSIGN_TICKETS
    
    -- DISTRIBUTOR (7)
    (29, 7, 1), (30, 7, 2), (31, 7, 3),
    (32, 7, 41), -- MANAGE_INVENTORY
    
    -- RETAILER (8)
    (33, 8, 1), (34, 8, 2), (35, 8, 3),
    (36, 8, 40), -- ACTIVATE_WARRANTY
    
    -- SERVICE_CENTER_ADMIN (9)
    (37, 9, 1), (38, 9, 2), (39, 9, 3),
    (40, 9, 31), -- ASSIGN_TICKETS
    (41, 9, 32), -- UPDATE_TICKETS
    
    -- TECHNICIAN (10)
    (42, 10, 1), (43, 10, 2), (44, 10, 3),
    (45, 10, 32) -- UPDATE_TICKETS
) AS source (id, role_id, permission_id)
ON target.id = source.id
WHEN MATCHED THEN
    UPDATE SET 
        role_id = source.role_id,
        permission_id = source.permission_id
WHEN NOT MATCHED THEN
    INSERT (id, role_id, permission_id)
    VALUES (source.id, source.role_id, source.permission_id);
GO

SET IDENTITY_INSERT tblRolePermissions OFF;
GO

DBCC CHECKIDENT ('tblRolePermissions', RESEED, 45);
GO

PRINT N'tblRolePermissions data merged successfully.';
GO
