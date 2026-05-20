EXEC dbo.usp_CreateUniqueKey N'tblCurrencies', N'iso_code';
EXEC dbo.usp_CreateUniqueKey N'tblCurrencies', N'numeric_code';
EXEC dbo.usp_CreateUniqueKey N'tblCurrencies', N'name';
EXEC dbo.usp_AddCheck N'tblCurrencies', N'iso_code', N'LEN(iso_code) = 3';



