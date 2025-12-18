DROP PROCEDURE IF EXISTS usp_CreateColumns_tblUsers;
DELIMITER $$

CREATE PROCEDURE usp_CreateColumns_tblUsers()
BEGIN
    DECLARE v_table_name VARCHAR(50) DEFAULT 'tblUsers';
    DECLARE v_required BOOLEAN DEFAULT TRUE;
    DECLARE v_optional BOOLEAN DEFAULT FALSE;

    CALL usp_AddColumn(v_table_name, 'created_by', 'BIGINT UNSIGNED', NULL, v_optional);
    CALL usp_AddColumn(v_table_name, 'updated_by', 'BIGINT UNSIGNED', NULL, v_optional);
END$$

DELIMITER ;

CALL usp_CreateColumns_tblUsers();
DROP PROCEDURE usp_CreateColumns_tblUsers;
