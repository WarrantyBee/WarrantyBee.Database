SET QUOTED_IDENTIFIER ON;
GO
DECLARE @v_now DATETIME = GETUTCDATE();
DECLARE @v_app_id VARCHAR(50) = 'app_mainbackend_2026';
DECLARE @v_secret VARCHAR(64) = 'wb_secret_main_backend_internal_2026_key'; -- Initial static secret for internal link
DECLARE @v_hash VARCHAR(64);

-- Manual hash for seeding (SHA256 of wb_secret_main_backend_internal_2026_key)
-- Using a known hash for this specific internal key to bootstrap the link
SET @v_hash = '8e5e786801061955b572236354897f1f0a514d7977464197475f3a0937a094a9';

IF NOT EXISTS (SELECT 1 FROM tblApiClients WHERE app_id = @v_app_id)
BEGIN
    INSERT INTO tblApiClients (internal_id, app_id, name, description, created_at, void)
    VALUES (NEWID(), @v_app_id, 'WarrantyBee Main Backend', 'Authoritative service layer', @v_now, 0);
END

DECLARE @v_client_id BIGINT = (SELECT id FROM tblApiClients WHERE app_id = @v_app_id);

IF NOT EXISTS (SELECT 1 FROM tblApiKeys WHERE client_id = @v_client_id AND key_prefix = 'wb_inter')
BEGIN
    INSERT INTO tblApiKeys (internal_id, client_id, key_prefix, secret_hash, expires_at, is_revoked, created_at, void)
    VALUES (NEWID(), @v_client_id, 'wb_inter', @v_hash, DATEADD(YEAR, 10, @v_now), 0, @v_now, 0);
END
GO
