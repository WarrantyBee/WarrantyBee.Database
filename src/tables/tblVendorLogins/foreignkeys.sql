CALL usp_CreateForeignKey(
    'tblVendorLogins',
    'user_id',
    'tblUsers',
    'id'
);

CALL usp_CreateForeignKey(
    'tblVendorLogins',
    'vendor_id',
    'tblVendors',
    'id'
);

