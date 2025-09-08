CALL usp_AddColumn('tblStates', 'name', 'VARCHAR(255)', NULL, TRUE);
CALL usp_AddColumn('tblStates', 'official_name', 'VARCHAR(150)', NULL, FALSE);
CALL usp_AddColumn('tblStates', 'iso_code', 'VARCHAR(10)', NULL, TRUE);
CALL usp_AddColumn('tblStates', 'capital', 'VARCHAR(100)', NULL, FALSE);
CALL usp_AddColumn('tblStates', 'timezone_id', 'BIGINT UNSIGNED', NULL, TRUE);
CALL usp_AddColumn('tblStates', 'phone_code', 'VARCHAR(10)', NULL, FALSE);
CALL usp_AddColumn('tblStates', 'country_id', 'BIGINT UNSIGNED', NULL, TRUE);