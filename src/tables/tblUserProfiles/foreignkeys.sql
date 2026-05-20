EXEC dbo.usp_CreateForeignKey N'tblUserProfiles', N'user_id', N'tblUsers', N'id';
EXEC dbo.usp_CreateForeignKey N'tblUserProfiles', N'country_id', N'tblCountries', N'id';
EXEC dbo.usp_CreateForeignKey N'tblUserProfiles', N'region_id', N'tblStates', N'id';
EXEC dbo.usp_CreateForeignKey N'tblUserProfiles', N'culture_id', N'tblCultures', N'id';



