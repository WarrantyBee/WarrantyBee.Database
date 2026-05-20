EXEC dbo.usp_CreateForeignKey N'tblCultures', N'language_id', N'tblLanguages', N'id';
EXEC dbo.usp_CreateForeignKey N'tblCultures', N'country_id', N'tblCountries', N'id';


