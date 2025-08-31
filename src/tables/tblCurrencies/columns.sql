CALL usp_AddColumn('tblCurrencies', 'iso_code', 'CHAR(3)', NULL, TRUE);
CALL usp_AddColumn('tblCurrencies', 'numeric_code', 'CHAR(3)', NULL, TRUE);
CALL usp_AddColumn('tblCurrencies', 'name', 'VARCHAR(100)', NULL, TRUE);
CALL usp_AddColumn('tblCurrencies', 'symbol', 'VARCHAR(10)', NULL, FALSE);
CALL usp_AddColumn('tblCurrencies', 'minor_unit', 'TINYINT UNSIGNED', '2', TRUE);