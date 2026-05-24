IF OBJECT_ID('dbo.usp_CreateColumns_tblClaims', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_CreateColumns_tblClaims;
GO

CREATE PROCEDURE dbo.usp_CreateColumns_tblClaims AS
BEGIN
    DECLARE @v_required BIT = 1;
    DECLARE @v_optional BIT = 0;

    EXEC dbo.usp_AddColumn N'tblClaims', 'claim_number', 'VARCHAR(50)', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblClaims', 'user_appliance_id', 'BIGINT', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblClaims', 'customer_id', 'BIGINT', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblClaims', 'business_id', 'BIGINT', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblClaims', 'issue_category', 'VARCHAR(100)', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblClaims', 'issue_description', 'NVARCHAR(MAX)', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblClaims', 'defect_media_url', 'VARCHAR(1024)', NULL, @v_optional;
    EXEC dbo.usp_AddColumn N'tblClaims', 'status', 'VARCHAR(50)', 'SUBMITTED', @v_required;
    EXEC dbo.usp_AddColumn N'tblClaims', 'resolution_notes', 'NVARCHAR(MAX)', NULL, @v_optional;
END
GO

EXEC dbo.usp_CreateColumns_tblClaims;
GO
