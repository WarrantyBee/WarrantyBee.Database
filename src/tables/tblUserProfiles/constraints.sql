CALL usp_CreateUniqueKey('tblUserProfiles', 'user_id');
CALL usp_AddCheck('tblUserProfiles', 'gender', 'gender IN (1, 2, 3)');
CALL usp_AddCheck('tblUserProfiles', 'date_of_birth', 'date_of_birth <= CURDATE()');
CALL usp_AddCheck('tblUserProfiles', 'phone_number', "TRIM(phone_number) <> ''");
CALL usp_AddCheck('tblUserProfiles', 'address_line1', "TRIM(address_line1) <> ''");
CALL usp_AddCheck('tblUserProfiles', 'city', "TRIM(city) <> ''");
CALL usp_AddCheck('tblUserProfiles', 'postal_code', "TRIM(postal_code) <> ''");