EXEC dbo.usp_CreateUniqueKey N'tblUsers', N'email';
EXEC dbo.usp_AddCheck N'tblUsers', N'firstname', N'TRIM(firstname) <> ''''';
EXEC dbo.usp_AddCheck N'tblUsers', N'lastname', N'TRIM(lastname) <> ''''';
EXEC dbo.usp_DropConstraint N'tblUsers', N'chk_tblUsers.password';

