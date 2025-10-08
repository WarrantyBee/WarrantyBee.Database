-- Index on vendor_id is useful for finding all companies for a given vendor.
CALL usp_CreateIndex('tblCompaniesVendors', 'vendor_id');