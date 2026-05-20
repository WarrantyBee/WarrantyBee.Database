EXEC dbo.usp_CreateForeignKey N'tblStates', N'country_id', N'tblCountries', N'id';
EXEC dbo.usp_CreateForeignKey N'tblStates', N'timezone_id', N'tblTimeZones', N'id';
GO
