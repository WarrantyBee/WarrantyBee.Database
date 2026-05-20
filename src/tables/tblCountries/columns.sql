IF OBJECT_ID('dbo.usp_CreateColumns_tblCountries', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_CreateColumns_tblCountries; GO

CREATE PROCEDURE dbo.usp_CreateColumns_tblCountries AS
BEGIN
    DECLARE @v_required BIT = 1;
    DECLARE @v_optional BIT = 0;

    EXEC dbo.usp_AddColumn N'tblCountries', 'iso2_code', 'CHAR(2)', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblCountries', 'iso3_code', 'CHAR(3)', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblCountries', 'numeric_code', 'CHAR(3)', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblCountries', 'name', 'VARCHAR(100)', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblCountries', 'official_name', 'VARCHAR(150)', NULL, @v_optional;
    EXEC dbo.usp_AddColumn N'tblCountries', 'capital', 'VARCHAR(100)', NULL, @v_optional;
    EXEC dbo.usp_AddColumn N'tblCountries', 'phone_code', 'VARCHAR(50)', NULL, @v_optional;
    EXEC dbo.usp_AddColumn N'tblCountries', 'currency_id', N'BIGINT', NULL, @v_optional;
    EXEC dbo.usp_DropColumn N'tblCountries', 'created_by';
    EXEC dbo.usp_DropColumn N'tblCountries', 'updated_by';
END
GO

EXEC dbo.usp_CreateColumns_tblCountries;
IF OBJECT_ID('dbo.usp_CreateColumns_tblCountries', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_CreateColumns_tblCountries; GO

