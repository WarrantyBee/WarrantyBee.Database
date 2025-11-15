CALL usp_CreateForeignKey('tblCultures', 'language_id', 'tblLanguages', 'id');
CALL usp_CreateForeignKey('tblCultures', 'country_id', 'tblCountries', 'id');