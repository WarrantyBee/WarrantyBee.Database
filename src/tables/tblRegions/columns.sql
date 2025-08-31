CALL usp_AddColumn('tblRegions', 'name', 'VARCHAR(255)', NULL, TRUE);
CALL usp_AddColumn('tblRegions', 'official_name', 'VARCHAR(150)', NULL, FALSE);
CALL usp_AddColumn('tblRegions', 'iso_code', 'VARCHAR(10)', NULL, TRUE);
CALL usp_AddColumn('tblRegions', 'capital', 'VARCHAR(100)', NULL, FALSE);
CALL usp_AddColumn('tblRegions', 'timezone_id', 'BIGINT', NULL, TRUE);
CALL usp_AddColumn('tblRegions', 'phone_code', 'VARCHAR(10)', NULL, FALSE);
CALL usp_AddColumn('tblRegions', 'currency_id', 'BIGINT', NULL, TRUE);
CALL usp_AddColumn('tblRegions', 'country_id', 'BIGINT', NULL, TRUE);