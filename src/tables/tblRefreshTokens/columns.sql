IF OBJECT_ID('dbo.usp_CreateColumns_tblRefreshTokens', 'P') IS NOT NULL 
    DROP PROCEDURE dbo.usp_CreateColumns_tblRefreshTokens; 
GO

CREATE PROCEDURE dbo.usp_CreateColumns_tblRefreshTokens AS
BEGIN
    DECLARE @v_required BIT = 1;
    DECLARE @v_optional BIT = 0;

    EXEC dbo.usp_AddColumn N'tblRefreshTokens', 'user_id', 'BIGINT', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblRefreshTokens', 'token_hash', 'VARCHAR(1024)', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblRefreshTokens', 'expires_at', 'DATETIME2', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblRefreshTokens', 'is_revoked', 'BIT', '0', @v_required;
    EXEC dbo.usp_AddColumn N'tblRefreshTokens', 'replaced_by_token_hash', 'VARCHAR(1024)', NULL, @v_optional;
END
GO

EXEC dbo.usp_CreateColumns_tblRefreshTokens;
GO

IF OBJECT_ID('dbo.usp_CreateColumns_tblRefreshTokens', 'P') IS NOT NULL 
    DROP PROCEDURE dbo.usp_CreateColumns_tblRefreshTokens; 
GO
