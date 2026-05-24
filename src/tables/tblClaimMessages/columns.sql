IF OBJECT_ID('dbo.usp_CreateColumns_tblClaimMessages', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_CreateColumns_tblClaimMessages;
GO

CREATE PROCEDURE dbo.usp_CreateColumns_tblClaimMessages AS
BEGIN
    DECLARE @v_required BIT = 1;
    DECLARE @v_optional BIT = 0;

    EXEC dbo.usp_AddColumn N'tblClaimMessages', 'claim_id', 'BIGINT', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblClaimMessages', 'sender_user_id', 'BIGINT', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblClaimMessages', 'message', 'NVARCHAR(MAX)', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblClaimMessages', 'attachment_url', 'VARCHAR(1024)', NULL, @v_optional;
END
GO

EXEC dbo.usp_CreateColumns_tblClaimMessages;
GO
