DROP PROCEDURE IF EXISTS usp_CreateColumns_tblPermissions;
DELIMITER $$

CREATE PROCEDURE usp_CreateColumns_tblPermissions()
BEGIN
    DECLARE v_table_name VARCHAR(100) DEFAULT 'tblPermissions';
    DECLARE v_required BOOLEAN DEFAULT TRUE;
    DECLARE v_optional BOOLEAN DEFAULT FALSE;

    CALL usp_AddColumn(v_table_name, 'name', 'VARCHAR(128)', NULL, v_required);
    CALL usp_AddColumn(v_table_name, 'description', 'VARCHAR(255)', NULL, v_required);
    CALL usp_DropColumn(v_table_name, 'created_by');
    CALL usp_DropColumn(v_table_name, 'updated_by');
END$$

DELIMITER ;

CALL usp_CreateColumns_tblPermissions();
DROP PROCEDURE usp_CreateColumns_tblPermissions;