IF OBJECT_ID('dbo.usp_CreateColumns_tblUserAppliances', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_CreateColumns_tblUserAppliances;
GO

CREATE PROCEDURE dbo.usp_CreateColumns_tblUserAppliances AS
BEGIN
    DECLARE @v_required BIT = 1;
    DECLARE @v_optional BIT = 0;

    EXEC dbo.usp_AddColumn N'tblUserAppliances', 'user_id', 'BIGINT', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblUserAppliances', 'product_id', 'BIGINT', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblUserAppliances', 'serial_number', 'VARCHAR(100)', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblUserAppliances', 'purchase_date', 'DATE', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblUserAppliances', 'warranty_end_date', 'DATE', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblUserAppliances', 'receipt_url', 'VARCHAR(1024)', NULL, @v_optional;
    EXEC dbo.usp_AddColumn N'tblUserAppliances', 'status', 'VARCHAR(50)', 'ACTIVE', @v_required;
END
GO

EXEC dbo.usp_CreateColumns_tblUserAppliances;
GO
