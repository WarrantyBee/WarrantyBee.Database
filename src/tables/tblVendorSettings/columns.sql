DROP PROCEDURE IF EXISTS usp_CreateColumns_tblVendorSettings;
DELIMITER $$

CREATE PROCEDURE usp_CreateColumns_tblVendorSettings()
BEGIN
    DECLARE v_table_name VARCHAR(64) DEFAULT 'tblVendorSettings';
    DECLARE v_required BOOLEAN DEFAULT TRUE;
    DECLARE v_optional BOOLEAN DEFAULT FALSE;

    CALL usp_AddColumn(v_table_name, 'vendor_id', 'BIGINT UNSIGNED', NULL, v_required);
    CALL usp_AddColumn(v_table_name, 'name', 'VARCHAR(255)', NULL, v_required);
    CALL usp_AddColumn(v_table_name, 'datatype', 'TINYINT', NULL, v_required);
    CALL usp_AddColumn(v_table_name, 'value', 'VARCHAR(1024)', NULL, v_required);
    CALL usp_AddColumn(v_table_name, 'description', 'VARCHAR(512)', NULL, v_required);
    CALL usp_AddColumn(v_table_name, 'sensitive', 'BOOLEAN', NULL, v_required);
END$$

DELIMITER ;

CALL usp_CreateColumns_tblVendorSettings();
DROP PROCEDURE usp_CreateColumns_tblVendorSettings;
