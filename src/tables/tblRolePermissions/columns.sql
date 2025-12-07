DROP PROCEDURE IF EXISTS usp_CreateColumns_tblRolePermissions;
DELIMITER $$

CREATE PROCEDURE usp_CreateColumns_tblRolePermissions()
BEGIN
    DECLARE v_table_name VARCHAR(100) DEFAULT 'tblRolePermissions';
    DECLARE v_required BOOLEAN DEFAULT TRUE;
    DECLARE v_optional BOOLEAN DEFAULT FALSE;

    CALL usp_AddColumn(v_table_name, 'role_id', 'BIGINT UNSIGNED', NULL, v_required);
    CALL usp_AddColumn(v_table_name, 'permission_id', 'BIGINT UNSIGNED', NULL, v_required);
    CALL usp_DropColumn(v_table_name, 'created_by');
    CALL usp_DropColumn(v_table_name, 'updated_by');
END$$

DELIMITER ;

CALL usp_CreateColumns_tblRolePermissions();
DROP PROCEDURE usp_CreateColumns_tblRolePermissions;