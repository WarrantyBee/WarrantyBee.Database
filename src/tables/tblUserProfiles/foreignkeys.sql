CALL usp_CreateForeignKey('tblUserProfiles', 'user_id', 'tblUsers', 'id');
CALL usp_CreateForeignKey('tblUserProfiles', 'country_id', 'tblCountries', 'id');
CALL usp_CreateForeignKey('tblUserProfiles', 'region_id', 'tblStates', 'id');
CALL usp_CreateForeignKey('tblUserProfiles', 'culture_id', 'tblCultures', 'id');