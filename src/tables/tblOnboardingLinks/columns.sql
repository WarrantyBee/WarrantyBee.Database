IF OBJECT_ID('dbo.usp_CreateColumns_tblOnboardingLinks', 'P') IS NOT NULL 
    DROP PROCEDURE dbo.usp_CreateColumns_tblOnboardingLinks; 
GO

CREATE PROCEDURE dbo.usp_CreateColumns_tblOnboardingLinks AS
BEGIN
    DECLARE @v_required BIT = 1;
    DECLARE @v_optional BIT = 0;

    EXEC dbo.usp_AddColumn N'tblOnboardingLinks', 'token', 'UNIQUEIDENTIFIER', 'NEWID()', @v_required;
    EXEC dbo.usp_AddColumn N'tblOnboardingLinks', 'email', 'VARCHAR(255)', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblOnboardingLinks', 'target_role_id', 'BIGINT', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblOnboardingLinks', 'target_business_id', 'BIGINT', NULL, @v_optional;
    EXEC dbo.usp_AddColumn N'tblOnboardingLinks', 'inviter_user_id', 'BIGINT', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblOnboardingLinks', 'expires_at', 'DATETIME2', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblOnboardingLinks', 'is_used', 'BIT', '0', @v_required;
END
GO

EXEC dbo.usp_CreateColumns_tblOnboardingLinks;
GO

IF OBJECT_ID('dbo.usp_CreateColumns_tblOnboardingLinks', 'P') IS NOT NULL 
    DROP PROCEDURE dbo.usp_CreateColumns_tblOnboardingLinks; 
GO
