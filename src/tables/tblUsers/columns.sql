IF OBJECT_ID('dbo.usp_CreateColumns_tblUsers', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_CreateColumns_tblUsers; GO

CREATE PROCEDURE dbo.usp_CreateColumns_tblUsers AS
BEGIN
    DECLARE @v_required BIT = 1;
    DECLARE @v_optional BIT = 0;

    EXEC dbo.usp_AddColumn N'tblUsers', 'firstname', 'VARCHAR(128)', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblUsers', 'lastname', 'VARCHAR(128)', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblUsers', 'email', 'VARCHAR(255)', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblUsers', 'password', 'VARCHAR(255)', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblUsers', 'is_2fa_enabled', N'BIT', '0', @v_required;
    EXEC dbo.usp_AddColumn N'tblUsers', 'login_token', 'VARCHAR(255)', NULL, @v_optional;
    EXEC dbo.usp_AddColumn N'tblUsers', 'password_updated_at', N'DATETIME2', NULL, @v_optional;
    EXEC dbo.usp_AddColumn N'tblUsers', 'accepted_tnc', N'BIT', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblUsers', 'accepted_pp', N'BIT', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblUsers', 'role_id', N'BIGINT', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblUsers', 'auth_provider', 'TINYINT', '1', @v_required;
    EXEC dbo.usp_AddColumn N'tblUsers', 'auth_provider_user_id', 'VARCHAR(1024)', NULL, @v_optional;
    EXEC dbo.usp_DropColumn N'tblUsers', 'created_by';
    EXEC dbo.usp_DropColumn N'tblUsers', 'updated_by';
    EXEC dbo.usp_AlterColumn N'tblUsers', 'password', 'VARCHAR(1024)', @v_optional, NULL;
END
GO

EXEC dbo.usp_CreateColumns_tblUsers;
IF OBJECT_ID('dbo.usp_CreateColumns_tblUsers', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_CreateColumns_tblUsers; GO
