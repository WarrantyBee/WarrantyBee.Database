DROP PROCEDURE IF EXISTS usp_CreateColumns_tblVendorContacts;
DELIMITER $$

CREATE PROCEDURE usp_CreateColumns_tblVendorContacts()
BEGIN
    DECLARE v_table_name VARCHAR(64) DEFAULT 'tblVendorContacts';
    DECLARE v_required BOOLEAN DEFAULT TRUE;
    DECLARE v_optional BOOLEAN DEFAULT FALSE;

    CALL usp_AddColumn(v_table_name, 'vendor_id', 'BIGINT UNSIGNED', NULL, v_required);
    CALL usp_AddColumn(v_table_name, 'type', 'TINYINT', NULL, v_required);
    CALL usp_AddColumn(v_table_name, 'email', 'VARCHAR(255)', NULL, v_required);
    CALL usp_AddColumn(v_table_name, 'phone_number', 'VARCHAR(32)', NULL, v_optional);
    CALL usp_AddColumn(v_table_name, 'phone_code', 'VARCHAR(8)', NULL, v_optional);
    CALL usp_AddColumn(v_table_name, 'country_id', 'BIGINT UNSIGNED', NULL, v_required);
    CALL usp_AddColumn(v_table_name, 'culture_id', 'BIGINT UNSIGNED', NULL, v_required);
    CALL usp_AddColumn(v_table_name, 'business_hours', 'JSON', NULL, v_required);

END$$

DELIMITER ;

CALL usp_CreateColumns_tblVendorContacts();
DROP PROCEDURE usp_CreateColumns_tblVendorContacts;
