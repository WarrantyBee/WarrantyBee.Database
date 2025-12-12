CALL usp_CreateUniqueKey('tblVendors', 'email');
CALL usp_AddCheck('tblVendors', 'email', 'email REGEXP ''^[a-zA-Z0-9][a-zA-Z0-9._-]*@[a-zA-Z0-9][a-zA-Z0-9._-]*\\.[a-zA-Z]{2,4}$''');