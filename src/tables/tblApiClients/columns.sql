IF OBJECT_ID('dbo.usp_CreateColumns_tblApiClients', 'P') IS NOT NULL 
    DROP PROCEDURE dbo.usp_CreateColumns_tblApiClients; 
GO

CREATE PROCEDURE dbo.usp_CreateColumns_tblApiClients AS
BEGIN
    DECLARE @v_required BIT = 1;
    DECLARE @v_optional BIT = 0;

    EXEC dbo.usp_AddColumn N'tblApiClients', 'app_id', 'VARCHAR(50)', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblApiClients', 'name', 'VARCHAR(128)', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblApiClients', 'description', 'NVARCHAR(512)', NULL, @v_optional;
END
GO

EXEC dbo.usp_CreateColumns_tblApiClients;
GO

IF OBJECT_ID('dbo.usp_CreateColumns_tblApiClients', 'P') IS NOT NULL 
    DROP PROCEDURE dbo.usp_CreateColumns_tblApiClients; 
GO
