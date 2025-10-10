CALL usp_CreateUniqueKey('tblTimeZones', 'name');
CALL usp_AddCheck('tblTimeZones', 'utc_offset_minutes', '`utc_offset_minutes` BETWEEN -720 AND 840');
CALL usp_AddCheck('tblTimeZones', 'current_offset_minutes', '`current_offset_minutes` BETWEEN -720 AND 840');