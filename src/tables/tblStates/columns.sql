IF OBJECT_ID('dbo.usp_CreateColumns_tblStates', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_CreateColumns_tblStates; GO

CREATE PROCEDURE dbo.usp_CreateColumns_tblStates AS
BEGIN
    DECLARE @v_required BIT = 1;
    DECLARE @v_optional BIT = 0;

    EXEC dbo.usp_AddColumn N'tblStates', 'name', 'VARCHAR(255)', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblStates', 'official_name', 'VARCHAR(150)', NULL, @v_optional;
    EXEC dbo.usp_AddColumn N'tblStates', 'iso_code', 'VARCHAR(10)', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblStates', 'capital', 'VARCHAR(100)', NULL, @v_optional;
    EXEC dbo.usp_AddColumn N'tblStates', 'timezone_id', N'BIGINT', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblStates', 'phone_code', 'VARCHAR(10)', NULL, @v_optional;
    EXEC dbo.usp_AddColumn N'tblStates', 'country_id', N'BIGINT', NULL, @v_required;
    EXEC dbo.usp_DropColumn N'tblStates', 'created_by';
    EXEC dbo.usp_DropColumn N'tblStates', 'updated_by';
END
GO

EXEC dbo.usp_CreateColumns_tblStates;
IF OBJECT_ID('dbo.usp_CreateColumns_tblStates', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_CreateColumns_tblStates; GO

