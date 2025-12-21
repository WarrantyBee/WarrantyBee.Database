CALL usp_CreateUniqueKey('tblUsers', 'email');
CALL usp_AddCheck('tblUsers', 'firstname', 'TRIM(firstname) <> ''''');
CALL usp_AddCheck('tblUsers', 'lastname', 'TRIM(lastname) <> ''''');
CALL usp_DropConstraint('tblUsers', 'chk_tblUsers.password');