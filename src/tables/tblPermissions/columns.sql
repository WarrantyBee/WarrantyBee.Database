IF OBJECT_ID('dbo.usp_CreateColumns_tblPermissions', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_CreateColumns_tblPermissions;
GO

CREATE PROCEDURE dbo.usp_CreateColumns_tblPermissions AS
BEGIN
    DECLARE @v_required BIT = 1;
    DECLARE @v_optional BIT = 0;

    EXEC dbo.usp_AddColumn N'tblPermissions', 'name', 'VARCHAR(100)', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblPermissions', 'description', 'VARCHAR(255)', NULL, @v_optional;
    
    EXEC dbo.usp_DropColumn N'tblPermissions', 'created_by';
    EXEC dbo.usp_DropColumn N'tblPermissions', 'updated_by';
END
GO

EXEC dbo.usp_CreateColumns_tblPermissions;
IF OBJECT_ID('dbo.usp_CreateColumns_tblPermissions', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_CreateColumns_tblPermissions;
GO


