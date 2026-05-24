IF OBJECT_ID('dbo.usp_CreateColumns_tblBusinessProfiles', 'P') IS NOT NULL 
    DROP PROCEDURE dbo.usp_CreateColumns_tblBusinessProfiles; 
GO

CREATE PROCEDURE dbo.usp_CreateColumns_tblBusinessProfiles AS
BEGIN
    DECLARE @v_required BIT = 1;
    DECLARE @v_optional BIT = 0;

    EXEC dbo.usp_AddColumn N'tblBusinessProfiles', 'name', 'VARCHAR(255)', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblBusinessProfiles', 'legal_name', 'VARCHAR(255)', NULL, @v_optional;
    EXEC dbo.usp_AddColumn N'tblBusinessProfiles', 'tax_id', 'VARCHAR(50)', NULL, @v_optional;
    EXEC dbo.usp_AddColumn N'tblBusinessProfiles', 'website', 'VARCHAR(255)', NULL, @v_optional;
    EXEC dbo.usp_AddColumn N'tblBusinessProfiles', 'logo_url', 'VARCHAR(1024)', NULL, @v_optional;
    EXEC dbo.usp_AddColumn N'tblBusinessProfiles', 'support_email', 'VARCHAR(255)', NULL, @v_optional;
    EXEC dbo.usp_AddColumn N'tblBusinessProfiles', 'is_verified', 'BIT', '0', @v_required;
    EXEC dbo.usp_AddColumn N'tblBusinessProfiles', 'owner_user_id', 'BIGINT', NULL, @v_required;
END
GO

EXEC dbo.usp_CreateColumns_tblBusinessProfiles;
GO

IF OBJECT_ID('dbo.usp_CreateColumns_tblBusinessProfiles', 'P') IS NOT NULL 
    DROP PROCEDURE dbo.usp_CreateColumns_tblBusinessProfiles; 
GO
