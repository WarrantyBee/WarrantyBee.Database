IF OBJECT_ID('dbo.usp_CreateColumns_tblSystemMacros', 'P') IS NOT NULL 
    DROP PROCEDURE dbo.usp_CreateColumns_tblSystemMacros; 
GO

CREATE PROCEDURE dbo.usp_CreateColumns_tblSystemMacros AS
BEGIN
    DECLARE @v_required BIT = 1;
    DECLARE @v_optional BIT = 0;

    EXEC dbo.usp_AddColumn N'tblSystemMacros', 'key', 'VARCHAR(128)', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblSystemMacros', 'value', 'NVARCHAR(MAX)', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblSystemMacros', 'description', 'NVARCHAR(512)', NULL, @v_optional;
    
    EXEC dbo.usp_DropColumn N'tblSystemMacros', 'created_by';
    EXEC dbo.usp_DropColumn N'tblSystemMacros', 'updated_by';
END
GO

EXEC dbo.usp_CreateColumns_tblSystemMacros;
GO

IF OBJECT_ID('dbo.usp_CreateColumns_tblSystemMacros', 'P') IS NOT NULL 
    DROP PROCEDURE dbo.usp_CreateColumns_tblSystemMacros; 
GO
