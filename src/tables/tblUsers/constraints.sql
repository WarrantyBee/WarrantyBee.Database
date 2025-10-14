CALL usp_CreateUniqueKey('tblUsers', 'email');
CALL usp_AddCheck('tblUsers', 'email', 'email REGEXP ''^[a-zA-Z0-9][a-zA-Z0-9._-]*@[a-zA-Z0-9][a-zA-Z0-9._-]*\\.[a-zA-Z]{2,4}$''');
CALL usp_AddCheck('tblUsers', 'firstname', 'TRIM(firstname) <> ''''');
CALL usp_AddCheck('tblUsers', 'lastname', 'TRIM(lastname) <> ''''');
CALL usp_AddCheck('tblUsers', 'password', 'password REGEXP ''^[a-f0-9]{64}$''');