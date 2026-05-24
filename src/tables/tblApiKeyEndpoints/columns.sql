IF OBJECT_ID('dbo.usp_CreateColumns_tblApiKeyEndpoints', 'P') IS NOT NULL 
    DROP PROCEDURE dbo.usp_CreateColumns_tblApiKeyEndpoints; 
GO

CREATE PROCEDURE dbo.usp_CreateColumns_tblApiKeyEndpoints AS
BEGIN
    DECLARE @v_required BIT = 1;
    DECLARE @v_optional BIT = 0;

    EXEC dbo.usp_AddColumn N'tblApiKeyEndpoints', 'api_key_id', 'BIGINT', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblApiKeyEndpoints', 'endpoint_path', 'VARCHAR(512)', NULL, @v_required;
END
GO

EXEC dbo.usp_CreateColumns_tblApiKeyEndpoints;
GO

IF OBJECT_ID('dbo.usp_CreateColumns_tblApiKeyEndpoints', 'P') IS NOT NULL 
    DROP PROCEDURE dbo.usp_CreateColumns_tblApiKeyEndpoints; 
GO
