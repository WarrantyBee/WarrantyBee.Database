EXEC dbo.usp_AddForeignKey N'tblUserAppliances', 'user_id', N'tblUsers', 'id';
EXEC dbo.usp_AddForeignKey N'tblUserAppliances', 'product_id', N'tblProducts', 'id';
GO
