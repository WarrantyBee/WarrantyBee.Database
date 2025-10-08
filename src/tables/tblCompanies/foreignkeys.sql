CALL usp_CreateForeignKey('tblCompanies', 'country_id', 'tblCountries', 'id');
CALL usp_CreateForeignKey('tblCompanies', 'state_id', 'tblStates', 'id');