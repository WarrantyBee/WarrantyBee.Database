IF OBJECT_ID('dbo.usp_CreateColumns_tblUserProfiles', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_CreateColumns_tblUserProfiles; GO

CREATE PROCEDURE dbo.usp_CreateColumns_tblUserProfiles AS
BEGIN
    DECLARE @v_required BIT = 1;
    DECLARE @v_optional BIT = 0;

    EXEC dbo.usp_AddColumn N'tblUserProfiles', 'phone_code', 'VARCHAR(8)', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblUserProfiles', 'phone_number', 'VARCHAR(15)', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblUserProfiles', 'gender', 'TINYINT', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblUserProfiles', 'date_of_birth', 'DATE', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblUserProfiles', 'address_line1', 'VARCHAR(255)', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblUserProfiles', 'address_line2', 'VARCHAR(255)', NULL, @v_optional;
    EXEC dbo.usp_AddColumn N'tblUserProfiles', 'region_id', N'BIGINT', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblUserProfiles', 'country_id', N'BIGINT', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblUserProfiles', 'city', 'VARCHAR(255)', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblUserProfiles', 'postal_code', 'VARCHAR(20)', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblUserProfiles', 'avatar_url', 'VARCHAR(512)', NULL, @v_optional;
    EXEC dbo.usp_AddColumn N'tblUserProfiles', 'user_id', N'BIGINT', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblUserProfiles', 'culture_id', N'BIGINT', '1', @v_required;
END
GO

EXEC dbo.usp_CreateColumns_tblUserProfiles;
IF OBJECT_ID('dbo.usp_CreateColumns_tblUserProfiles', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_CreateColumns_tblUserProfiles; GO

