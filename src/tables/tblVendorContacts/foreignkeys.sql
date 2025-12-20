CALL usp_CreateForeignKey('tblVendorContacts', 'vendor_id', 'tblVendors', 'id');
CALL usp_CreateForeignKey('tblVendorContacts', 'country_id', 'tblCountries', 'id');
CALL usp_CreateForeignKey('tblVendorContacts', 'culture_id', 'tblCultures', 'id');
CALL usp_CreateForeignKey('tblVendorContacts', 'created_by', 'tblAdminUsers', 'id');
CALL usp_CreateForeignKey('tblVendorContacts', 'updated_by', 'tblAdminUsers', 'id');