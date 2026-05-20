IF OBJECT_ID('dbo.usp_CreateColumns_tblCurrencies', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_CreateColumns_tblCurrencies; GO

CREATE PROCEDURE dbo.usp_CreateColumns_tblCurrencies AS
BEGIN
    DECLARE @v_required BIT = 1;
    DECLARE @v_optional BIT = 0;

    EXEC dbo.usp_AddColumn N'tblCurrencies', 'iso_code', 'CHAR(3)', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblCurrencies', 'numeric_code', 'CHAR(3)', NULL, @v_optional;
    EXEC dbo.usp_AddColumn N'tblCurrencies', 'name', 'VARCHAR(100)', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblCurrencies', 'symbol', 'VARCHAR(10)', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblCurrencies', 'minor_unit', N'TINYINT', '2', @v_required;
    EXEC dbo.usp_DropColumn N'tblCurrencies', 'created_by';
    EXEC dbo.usp_DropColumn N'tblCurrencies', 'updated_by';
END
GO

EXEC dbo.usp_CreateColumns_tblCurrencies;
IF OBJECT_ID('dbo.usp_CreateColumns_tblCurrencies', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_CreateColumns_tblCurrencies; GO
