IF OBJECT_ID('dbo.usp_CreateColumns_tblOtp', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_CreateColumns_tblOtp;
GO

CREATE PROCEDURE dbo.usp_CreateColumns_tblOtp AS
BEGIN
    DECLARE @v_required BIT = 1;
    DECLARE @v_optional BIT = 0;

    EXEC dbo.usp_AddColumn N'tblOtp', 'recipient_id', N'BIGINT', NULL, @v_optional;
    EXEC dbo.usp_AddColumn N'tblOtp', 'value', 'VARCHAR(255)', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblOtp', 'recipient', 'VARCHAR(255)', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblOtp', 'type', 'TINYINT', NULL, @v_required;
    EXEC dbo.usp_DropColumn N'tblOtp', 'created_by';
    EXEC dbo.usp_DropColumn N'tblOtp', 'updated_by';
END
GO

EXEC dbo.usp_CreateColumns_tblOtp;
IF OBJECT_ID('dbo.usp_CreateColumns_tblOtp', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_CreateColumns_tblOtp;
GO


