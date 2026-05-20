EXEC dbo.usp_CreateUniqueKey N'tblUserProfiles', N'user_id';
EXEC dbo.usp_AddCheck N'tblUserProfiles', N'gender', N'gender IN (1, 2, 3)';
EXEC dbo.usp_AddCheck N'tblUserProfiles', N'date_of_birth', N'date_of_birth <= CAST(GETUTCDATE() AS DATE)';
EXEC dbo.usp_AddCheck N'tblUserProfiles', N'phone_number',N'LTRIM(RTRIM(phone_number)) <> ''''';
EXEC dbo.usp_AddCheck N'tblUserProfiles', N'address_line1', N'LTRIM(RTRIM(address_line1)) <> ''''';
EXEC dbo.usp_AddCheck N'tblUserProfiles', N'city', N'LTRIM(RTRIM(city)) <> ''''';
EXEC dbo.usp_AddCheck N'tblUserProfiles', N'postal_code', N'LTRIM(RTRIM(postal_code)) <> ''''';



