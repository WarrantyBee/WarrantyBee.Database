CALL usp_CreateForeignKey('tblUserProfiles', 'user_id', 'tblUsers', 'id');
CALL usp_CreateForeignKey('tblUserProfiles', 'country_id', 'tblCountries', 'id');
CALL usp_CreateForeignKey('tblUserProfiles', 'state_id', 'tblStates', 'id');