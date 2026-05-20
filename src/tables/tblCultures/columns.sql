IF OBJECT_ID('dbo.usp_CreateColumns_tblCultures', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_CreateColumns_tblCultures; GO

CREATE PROCEDURE dbo.usp_CreateColumns_tblCultures AS
BEGIN
    DECLARE @v_required BIT = 1;
    DECLARE @v_optional BIT = 0;

    EXEC dbo.usp_AddColumn N'tblCultures', 'iso_code', 'VARCHAR(10)', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblCultures', 'rtl', 'BIT', '0', @v_required;
    EXEC dbo.usp_AddColumn N'tblCultures', 'language_id', 'BIGINT', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblCultures', 'country_id', 'BIGINT', NULL, @v_optional;

    EXEC dbo.usp_DropColumn N'tblCultures', 'created_by';
    EXEC dbo.usp_DropColumn N'tblCultures', 'updated_by';
END
GO

EXEC dbo.usp_CreateColumns_tblCultures;
IF OBJECT_ID('dbo.usp_CreateColumns_tblCultures', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_CreateColumns_tblCultures; GO

