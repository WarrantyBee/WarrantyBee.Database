EXEC dbo.usp_CreateUniqueKey N'tblUserProfiles', N'user_id';
EXEC dbo.usp_AddCheck N'tblUserProfiles', N'gender', N'gender IN (1, 2, 3)';
EXEC dbo.usp_AddCheck N'tblUserProfiles', N'date_of_birth', N'date_of_birth <= CURDATE()';
EXEC dbo.usp_AddCheck N'tblUserProfiles', N'phone_number',N'TRIM(phone_number) <> ''''';
EXEC dbo.usp_AddCheck N'tblUserProfiles', N'address_line1', N'TRIM(address_line1) <> ''''';
EXEC dbo.usp_AddCheck N'tblUserProfiles', N'city', N'TRIM(city) <> ''''';
EXEC dbo.usp_AddCheck N'tblUserProfiles', N'postal_code', N'TRIM(postal_code) <> ''''';

