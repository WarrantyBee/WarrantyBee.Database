CALL usp_AddColumn('tblVendors', 'name', 'VARCHAR(255)', NULL, TRUE);
CALL usp_AddColumn('tblVendors', 'address', 'VARCHAR(255)', NULL, FALSE);
CALL usp_AddColumn('tblVendors', 'city', 'VARCHAR(100)', NULL, FALSE);
CALL usp_AddColumn('tblVendors', 'state_id', 'BIGINT UNSIGNED', NULL, FALSE);
CALL usp_AddColumn('tblVendors', 'zip_code', 'VARCHAR(20)', NULL, FALSE);
CALL usp_AddColumn('tblVendors', 'country_id', 'BIGINT UNSIGNED', NULL, TRUE);
CALL usp_AddColumn('tblVendors', 'support_email', 'VARCHAR(255)', NULL, FALSE);