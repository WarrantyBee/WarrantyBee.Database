IF OBJECT_ID('dbo.usp_CreateColumns_tblRoles', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_CreateColumns_tblRoles; GO

CREATE PROCEDURE dbo.usp_CreateColumns_tblRoles AS
BEGIN
    DECLARE @v_required BIT = 1;
    DECLARE @v_optional BIT = 0;

    EXEC dbo.usp_AddColumn N'tblRoles', 'name', 'VARCHAR(50)', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblRoles', 'description', 'VARCHAR(255)', NULL, @v_optional;
    
    EXEC dbo.usp_DropColumn N'tblRoles', 'created_by';
    EXEC dbo.usp_DropColumn N'tblRoles', 'updated_by';
END
GO

EXEC dbo.usp_CreateColumns_tblRoles;
IF OBJECT_ID('dbo.usp_CreateColumns_tblRoles', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_CreateColumns_tblRoles; GO

