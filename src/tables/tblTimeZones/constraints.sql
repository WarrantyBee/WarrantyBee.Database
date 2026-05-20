EXEC dbo.usp_CreateUniqueKey N'tblTimeZones', N'name';
EXEC dbo.usp_AddCheck N'tblTimeZones', N'utc_offset_minutes', N'`utc_offset_minutes` BETWEEN -720 AND 840';
EXEC dbo.usp_AddCheck N'tblTimeZones', N'current_offset_minutes', N'`current_offset_minutes` BETWEEN -720 AND 840';

