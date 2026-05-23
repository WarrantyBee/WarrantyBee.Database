SET QUOTED_IDENTIFIER ON;
GO
DECLARE @v_now DATETIME = GETUTCDATE();

MERGE INTO tblApiClients AS target
USING (VALUES 
    ('app_eventmanager_2026', 'EventManager Microservice', 'Handles webhook ingestion and delivery'),
    ('app_jobscheduler_2026', 'JobScheduler Microservice', 'Manages recurring and background Hangfire jobs'),
    ('app_webportal_2026', 'WarrantyBee Web Portal', 'Main frontend application')
) AS source (app_id, name, description)
ON (target.app_id = source.app_id)
WHEN MATCHED THEN
    UPDATE SET 
        name = source.name,
        description = source.description,
        updated_at = @v_now
WHEN NOT MATCHED THEN
    INSERT (internal_id, app_id, name, description, created_at, void)
    VALUES (NEWID(), source.app_id, source.name, source.description, @v_now, 0);
GO
