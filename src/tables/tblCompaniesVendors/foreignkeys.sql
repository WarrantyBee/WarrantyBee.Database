CALL usp_CreateForeignKey('tblCompaniesVendors', 'company_id', 'tblCompanies', 'id');
CALL usp_CreateForeignKey('tblCompaniesVendors', 'vendor_id', 'tblVendors', 'id');