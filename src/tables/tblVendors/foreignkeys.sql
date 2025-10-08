CALL usp_CreateForeignKey('tblVendors', 'country_id', 'tblCountries', 'id');
CALL usp_CreateForeignKey('tblVendors', 'state_id', 'tblStates', 'id');