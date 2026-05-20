IF OBJECT_ID('dbo.usp_CreateColumns_tblTimeZones', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_CreateColumns_tblTimeZones; GO

CREATE PROCEDURE dbo.usp_CreateColumns_tblTimeZones AS
BEGIN
    DECLARE @v_required BIT = 1;
    DECLARE @v_optional BIT = 0;

    EXEC dbo.usp_AddColumn N'tblTimeZones', 'name', 'VARCHAR(100)', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblTimeZones', 'abbreviation', 'VARCHAR(10)', NULL, @v_optional;
    EXEC dbo.usp_AddColumn N'tblTimeZones', 'utc_offset_minutes', 'SMALLINT', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblTimeZones', 'observes_dst', N'BIT', '0', @v_required;
    EXEC dbo.usp_AddColumn N'tblTimeZones', 'current_offset_minutes', 'SMALLINT', NULL, @v_required;
    EXEC dbo.usp_DropColumn N'tblTimeZones', 'created_by';
    EXEC dbo.usp_DropColumn N'tblTimeZones', 'updated_by';
END
GO

EXEC dbo.usp_CreateColumns_tblTimeZones;
IF OBJECT_ID('dbo.usp_CreateColumns_tblTimeZones', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_CreateColumns_tblTimeZones; GO

