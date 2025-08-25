CALL usp_AddColumn('tblUsers', 'firstname', 'VARCHAR(128)', NULL, TRUE);
CALL usp_AddColumn('tblUsers', 'lastname', 'VARCHAR(128)', NULL, TRUE);
CALL usp_AddColumn('tblUsers', 'email', 'VARCHAR(255)', NULL, TRUE);
CALL usp_AddColumn('tblUsers', 'password', 'VARCHAR(255)', NULL, TRUE);