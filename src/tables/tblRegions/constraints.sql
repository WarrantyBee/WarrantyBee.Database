CALL usp_CreateUniqueKey('tblRegions', 'country_id, iso_code');
CALL usp_CreateUniqueKey('tblRegions', 'country_id, name');
CALL usp_AddCheck('tblRegions', 'phone_code', '`phone_code` IS NULL OR phone_code REGEXP ''^\\+[0-9]+$''');