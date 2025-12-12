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

CALL usp_CreateForeignKey
(   'tblVendorLogins',
    'created_by',
    'tblAdminUsers',
    'id'
);

CALL usp_CreateForeignKey
(   'tblVendorLogins',
    'updated_by',
    'tblAdminUsers',
    'id'
);