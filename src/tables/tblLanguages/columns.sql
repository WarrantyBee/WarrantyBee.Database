IF OBJECT_ID('dbo.usp_CreateColumns_tblLanguages', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_CreateColumns_tblLanguages; GO

CREATE PROCEDURE dbo.usp_CreateColumns_tblLanguages AS
BEGIN
    DECLARE @v_required BIT = 1;
    DECLARE @v_optional BIT = 0;

    EXEC dbo.usp_AddColumn N'tblLanguages', 'name', 'VARCHAR(100)', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblLanguages', 'iso_code', 'CHAR(2)', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblLanguages', 'native_name', 'NVARCHAR(100)', NULL, @v_optional;
    
    EXEC dbo.usp_DropColumn N'tblLanguages', 'created_by';
    EXEC dbo.usp_DropColumn N'tblLanguages', 'updated_by';
END
GO

EXEC dbo.usp_CreateColumns_tblLanguages;
IF OBJECT_ID('dbo.usp_CreateColumns_tblLanguages', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_CreateColumns_tblLanguages; GO

