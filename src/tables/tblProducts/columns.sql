CALL usp_AddColumn('tblProducts', 'name', 'VARCHAR(200)', NULL, TRUE);
CALL usp_AddColumn('tblProducts', 'sku_id', 'VARCHAR(100)', NULL, TRUE);
CALL usp_AddColumn('tblProducts', 'category_id', 'VARCHAR(100)', NULL, TRUE);
CALL usp_AddColumn('tblProducts', 'price', 'DECIMAL(10,2)', NULL, TRUE);