SET QUOTED_IDENTIFIER ON;
GO
DECLARE @v_now DATETIME = GETUTCDATE();

MERGE INTO tblSystemMacros AS target
USING (VALUES 
    ('ORGANIZATION_NAME', 'WarrantyBee', 'The official name of the organization'),
    ('SUPPORT_EMAIL', 'support@warrantybee.com', 'Contact email for customer support'),
    ('PRIVACY_POLICY_URL', 'https://warrantybee.com/privacy', 'Link to the privacy policy page'),
    ('LOG_IN_URL', 'https://warrantybee.com/login', 'Link to the user login page'),
    ('WEBSITE_URL', 'https://warrantybee.com', 'Main website URL')
) AS source ([key], [value], [description])
ON (target.[key] = source.[key])
WHEN MATCHED THEN
    UPDATE SET 
        [value] = source.[value],
        [description] = source.[description],
        updated_at = @v_now
WHEN NOT MATCHED THEN
    INSERT (internal_id, [key], [value], [description], created_at, void)
    VALUES (NEWID(), source.[key], source.[value], source.[description], @v_now, 0);
GO
