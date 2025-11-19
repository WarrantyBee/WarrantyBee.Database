DROP PROCEDURE IF EXISTS usp_CreateColumns_tblCultures;
DELIMITER $$

CREATE PROCEDURE usp_CreateColumns_tblCultures()
BEGIN
    DECLARE v_table_name VARCHAR(50) DEFAULT 'tblCultures';
    DECLARE v_required BOOLEAN DEFAULT TRUE;
    DECLARE v_optional BOOLEAN DEFAULT FALSE;

    CALL usp_DropColumn(v_table_name, 'created_by');
    CALL usp_DropColumn(v_table_name, 'updated_by');
    CALL usp_AddColumn(v_table_name, 'iso_code', 'VARCHAR(5)', NULL, v_required);
    CALL usp_AddColumn(v_table_name, 'rtl', 'BOOLEAN', '0', v_optional);
    CALL usp_AddColumn(v_table_name, 'language_id', 'BIGINT UNSIGNED', NULL, v_required);
    CALL usp_AddColumn(v_table_name, 'country_id', 'BIGINT UNSIGNED', NULL, v_required);
END$$

DELIMITER ;

CALL usp_CreateColumns_tblCultures();
DROP PROCEDURE usp_CreateColumns_tblCultures;