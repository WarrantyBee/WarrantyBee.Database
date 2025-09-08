CALL usp_CreateUniqueKey('tblStates', 'country_id, iso_code');
CALL usp_CreateUniqueKey('tblStates', 'country_id, name');
CALL usp_AddCheck('tblStates', 'phone_code', '`phone_code` IS NULL OR phone_code REGEXP ''^\\+[0-9]+$''');