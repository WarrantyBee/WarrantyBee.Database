CALL usp_AddColumn('tblCompanies', 'name', 'VARCHAR(255)', NULL, TRUE);
CALL usp_AddColumn('tblCompanies', 'address', 'VARCHAR(255)', NULL, FALSE);
CALL usp_AddColumn('tblCompanies', 'city', 'VARCHAR(100)', NULL, FALSE);
CALL usp_AddColumn('tblCompanies', 'state_id', 'BIGINT UNSIGNED', NULL, FALSE);
CALL usp_AddColumn('tblCompanies', 'zip_code', 'VARCHAR(20)', NULL, FALSE);
CALL usp_AddColumn('tblCompanies', 'country_id', 'BIGINT UNSIGNED', NULL, TRUE);
CALL usp_AddColumn('tblCompanies', 'support_email', 'VARCHAR(255)', NULL, FALSE);