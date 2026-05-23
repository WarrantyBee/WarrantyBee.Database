IF OBJECT_ID('dbo.usp_CreateColumns_tblApiKeys', 'P') IS NOT NULL 
    DROP PROCEDURE dbo.usp_CreateColumns_tblApiKeys; 
GO

CREATE PROCEDURE dbo.usp_CreateColumns_tblApiKeys AS
BEGIN
    DECLARE @v_required BIT = 1;
    DECLARE @v_optional BIT = 0;

    EXEC dbo.usp_AddColumn N'tblApiKeys', 'client_id', 'BIGINT', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblApiKeys', 'key_prefix', 'VARCHAR(20)', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblApiKeys', 'secret_hash', 'VARCHAR(1024)', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblApiKeys', 'expires_at', 'DATETIME', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblApiKeys', 'is_revoked', 'BIT', '0', @v_required;
END
GO

EXEC dbo.usp_CreateColumns_tblApiKeys;
GO

IF OBJECT_ID('dbo.usp_CreateColumns_tblApiKeys', 'P') IS NOT NULL 
    DROP PROCEDURE dbo.usp_CreateColumns_tblApiKeys; 
GO
