EXEC dbo.usp_CreateUniqueKey N'tblCountries', N'iso2_code';
EXEC dbo.usp_CreateUniqueKey N'tblCountries', N'iso3_code';
EXEC dbo.usp_CreateUniqueKey N'tblCountries', N'numeric_code';
EXEC dbo.usp_CreateUniqueKey N'tblCountries', N'name';

EXEC dbo.usp_AddCheck N'tblCountries', N'name', N'CHAR_LENGTH(`name`) > 0';
EXEC dbo.usp_AddCheck N'tblCountries', N'official_name', N'`official_name` IS NULL OR CHAR_LENGTH(`official_name`) > 0';
EXEC dbo.usp_AddCheck N'tblCountries', N'capital', N'`capital` IS NULL OR CHAR_LENGTH(`capital`) > 0';

