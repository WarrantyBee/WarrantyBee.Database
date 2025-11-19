DROP PROCEDURE IF EXISTS usp_CreateColumns_tblLanguages;
DELIMITER $$

CREATE PROCEDURE usp_CreateColumns_tblLanguages()
BEGIN
    DECLARE v_table_name VARCHAR(50) DEFAULT 'tblLanguages';
    DECLARE v_required BOOLEAN DEFAULT TRUE;
    DECLARE v_optional BOOLEAN DEFAULT FALSE;

    CALL usp_DropColumn(v_table_name, 'created_by');
    CALL usp_DropColumn(v_table_name, 'updated_by');
    CALL usp_AddColumn(v_table_name, 'name', 'VARCHAR(50)', NULL, v_required);
    CALL usp_AddColumn(v_table_name, 'native_name', 'VARCHAR(50)', NULL, v_required);
    CALL usp_AddColumn(v_table_name, 'iso_code', 'VARCHAR(5)', NULL, v_required);
END$$

DELIMITER ;

CALL usp_CreateColumns_tblLanguages();
DROP PROCEDURE usp_CreateColumns_tblLanguages;