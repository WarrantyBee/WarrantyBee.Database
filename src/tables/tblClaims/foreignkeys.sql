EXEC dbo.usp_AddForeignKey N'tblClaims', 'user_appliance_id', N'tblUserAppliances', 'id';
EXEC dbo.usp_AddForeignKey N'tblClaims', 'customer_id', N'tblUsers', 'id';
EXEC dbo.usp_AddForeignKey N'tblClaims', 'business_id', N'tblBusinessProfiles', 'id';
GO
