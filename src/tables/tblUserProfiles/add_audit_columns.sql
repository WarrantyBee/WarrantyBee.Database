DROP PROCEDURE IF EXISTS usp_CreateColumns_tblUserProfiles;
DELIMITER $$

CREATE PROCEDURE usp_CreateColumns_tblUserProfiles()
BEGIN
    DECLARE v_table_name VARCHAR(50) DEFAULT 'tblUserProfiles';
    DECLARE v_required BOOLEAN DEFAULT TRUE;
    DECLARE v_optional BOOLEAN DEFAULT FALSE;

    CALL usp_AddColumn(v_table_name, 'created_by', 'BIGINT UNSIGNED', NULL, v_optional);
    CALL usp_AddColumn(v_table_name, 'updated_by', 'BIGINT UNSIGNED', NULL, v_optional);
END$$

DELIMITER ;

CALL usp_CreateColumns_tblUserProfiles();
DROP PROCEDURE usp_CreateColumns_tblUserProfiles;
