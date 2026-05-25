IF OBJECT_ID('dbo.usp_CreateColumns_tblSystemStatus', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_CreateColumns_tblSystemStatus;
GO

CREATE PROCEDURE dbo.usp_CreateColumns_tblSystemStatus AS
BEGIN
    DECLARE @v_required BIT = 1;
    DECLARE @v_optional BIT = 0;

    EXEC dbo.usp_AddColumn N'tblSystemStatus', 'category', 'VARCHAR(50)', NULL, @v_required; -- e.g. 'CLAIM', 'APPLIANCE'
    EXEC dbo.usp_AddColumn N'tblSystemStatus', 'code', 'VARCHAR(50)', NULL, @v_required;     -- e.g. 'SUBMITTED'
    EXEC dbo.usp_AddColumn N'tblSystemStatus', 'display_name', 'VARCHAR(100)', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblSystemStatus', 'color_hex', 'VARCHAR(10)', NULL, @v_optional;
END
GO

EXEC dbo.usp_CreateColumns_tblSystemStatus;
GO
