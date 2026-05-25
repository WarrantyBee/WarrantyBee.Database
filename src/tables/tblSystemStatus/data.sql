MERGE INTO tblSystemStatus AS target
USING (VALUES 
    ('APPLIANCE', 'ACTIVE', 'Active Warranty', '#67C23A'),
    ('APPLIANCE', 'EXPIRED', 'Warranty Expired', '#F56C6C'),
    ('APPLIANCE', 'CLAIM_PENDING', 'Under Repair', '#E6A23C'),
    
    ('CLAIM', 'SUBMITTED', 'Submitted', '#909399'),
    ('CLAIM', 'UNDER_REVIEW', 'In Review', '#409EFF'),
    ('CLAIM', 'APPROVED', 'Approved', '#67C23A'),
    ('CLAIM', 'REJECTED', 'Rejected', '#F56C6C'),
    ('CLAIM', 'RESOLVED', 'Resolved', '#67C23A')
) AS source (category, code, display_name, color_hex)
ON (target.category = source.category AND target.code = source.code)
WHEN MATCHED THEN
    UPDATE SET 
        display_name = source.display_name,
        color_hex = source.color_hex
WHEN NOT MATCHED THEN
    INSERT (internal_id, category, code, display_name, color_hex, created_at, void)
    VALUES (NEWID(), source.category, source.code, source.display_name, source.color_hex, GETUTCDATE(), 0);
GO
