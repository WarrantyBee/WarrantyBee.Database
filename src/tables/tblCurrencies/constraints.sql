CALL usp_CreateUniqueKey('tblCurrencies', 'iso_code');
CALL usp_CreateUniqueKey('tblCurrencies', 'numeric_code');
CALL usp_CreateUniqueKey('tblCurrencies', 'name');
CALL usp_AddCheck('tblCurrencies', 'iso_code', 'CHAR_LENGTH(`iso_code`) = 3');