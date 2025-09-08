CALL usp_AddColumn('tblCountries', 'iso2_code', 'CHAR(2)', NULL, TRUE);
CALL usp_AddColumn('tblCountries', 'iso3_code', 'CHAR(3)', NULL, TRUE);
CALL usp_AddColumn('tblCountries', 'numeric_code', 'CHAR(3)', NULL, TRUE);
CALL usp_AddColumn('tblCountries', 'name', 'VARCHAR(100)', NULL, TRUE);
CALL usp_AddColumn('tblCountries', 'official_name', 'VARCHAR(150)', NULL, FALSE);
CALL usp_AddColumn('tblCountries', 'capital', 'VARCHAR(100)', NULL, FALSE);
CALL usp_AddColumn('tblCountries', 'phone_code', 'VARCHAR(10)', NULL, TRUE);
CALL usp_AddColumn('tblCountries', 'currency_id', 'BIGINT UNSIGNED', NULL, FALSE);