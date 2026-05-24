IF OBJECT_ID('dbo.usp_CreateColumns_tblProducts', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_CreateColumns_tblProducts;
GO

CREATE PROCEDURE dbo.usp_CreateColumns_tblProducts AS
BEGIN
    DECLARE @v_required BIT = 1;
    DECLARE @v_optional BIT = 0;

    EXEC dbo.usp_AddColumn N'tblProducts', 'business_id', 'BIGINT', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblProducts', 'sku', 'VARCHAR(50)', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblProducts', 'name', 'VARCHAR(255)', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblProducts', 'category', 'VARCHAR(100)', NULL, @v_required;
    EXEC dbo.usp_AddColumn N'tblProducts', 'image_url', 'VARCHAR(1024)', NULL, @v_optional;
    EXEC dbo.usp_AddColumn N'tblProducts', 'default_warranty_months', 'INT', '12', @v_required;
END
GO

EXEC dbo.usp_CreateColumns_tblProducts;
GO
