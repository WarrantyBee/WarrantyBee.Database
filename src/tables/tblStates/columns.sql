DROP PROCEDURE IF EXISTS usp_CreateColumns_tblStates;
DELIMITER $$

CREATE PROCEDURE usp_CreateColumns_tblStates()
BEGIN
    DECLARE v_required BOOLEAN DEFAULT TRUE;
    DECLARE v_optional BOOLEAN DEFAULT FALSE;

    CALL usp_AddColumn('tblStates', 'name', 'VARCHAR(255)', NULL, v_required);
    CALL usp_AddColumn('tblStates', 'official_name', 'VARCHAR(150)', NULL, v_optional);
    CALL usp_AddColumn('tblStates', 'iso_code', 'VARCHAR(10)', NULL, v_required);
    CALL usp_AddColumn('tblStates', 'capital', 'VARCHAR(100)', NULL, v_optional);
    CALL usp_AddColumn('tblStates', 'timezone_id', 'BIGINT UNSIGNED', NULL, v_required);
    CALL usp_AddColumn('tblStates', 'phone_code', 'VARCHAR(10)', NULL, v_optional);
    CALL usp_AddColumn('tblStates', 'country_id', 'BIGINT UNSIGNED', NULL, v_required);
    CALL usp_DropColumn('tblStates', 'created_by');
    CALL usp_DropColumn('tblStates', 'updated_by');
END$$

DELIMITER ;

CALL usp_CreateColumns_tblStates();
DROP PROCEDURE usp_CreateColumns_tblStates;