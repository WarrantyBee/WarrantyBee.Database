DROP PROCEDURE IF EXISTS usp_CreateColumns_tblPasswordLogs;
DELIMITER $$

CREATE PROCEDURE usp_CreateColumns_tblPasswordLogs()
BEGIN
    DECLARE v_table_name VARCHAR(50) DEFAULT 'tblPasswordLogs';
    DECLARE v_required BOOLEAN DEFAULT TRUE;
    DECLARE v_optional BOOLEAN DEFAULT FALSE;

    CALL usp_AddColumn(v_table_name, 'password', 'VARCHAR(255)', NULL, v_required);
    CALL usp_AddColumn(v_table_name, 'user_id', 'BIGINT UNSIGNED', NULL, v_required);
END$$

DELIMITER ;

CALL usp_CreateColumns_tblPasswordLogs();
DROP PROCEDURE usp_CreateColumns_tblPasswordLogs;