CALL usp_CreateForeignKey
(   'tblVendors',
    'created_by',
    'tblAdminUsers',
    'id'
);

CALL usp_CreateForeignKey
(   'tblVendors',
    'updated_by',
    'tblAdminUsers',
    'id'
);