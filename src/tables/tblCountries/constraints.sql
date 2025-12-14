CALL usp_CreateUniqueKey('tblCountries', 'iso2_code');
CALL usp_CreateUniqueKey('tblCountries', 'iso3_code');
CALL usp_CreateUniqueKey('tblCountries', 'numeric_code');
CALL usp_CreateUniqueKey('tblCountries', 'name');

CALL usp_AddCheck('tblCountries', 'name', 'CHAR_LENGTH(`name`) > 0');
CALL usp_AddCheck('tblCountries', 'official_name', '`official_name` IS NULL OR CHAR_LENGTH(`official_name`) > 0');
CALL usp_AddCheck('tblCountries', 'capital', '`capital` IS NULL OR CHAR_LENGTH(`capital`) > 0');