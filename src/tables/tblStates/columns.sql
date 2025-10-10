DELIMITER $$

CREATE PROCEDURE usp_CreateColumns_tblStates()
BEGIN
    DECLARE @required BOOLEAN DEFAULT TRUE;
    DECLARE @optional BOOLEAN DEFAULT FALSE;

    CALL usp_AddColumn('tblStates', 'name', 'VARCHAR(255)', NULL, @required);
    CALL usp_AddColumn('tblStates', 'official_name', 'VARCHAR(150)', NULL, @optional);
    CALL usp_AddColumn('tblStates', 'iso_code', 'VARCHAR(10)', NULL, @required);
    CALL usp_AddColumn('tblStates', 'capital', 'VARCHAR(100)', NULL, @optional);
    CALL usp_AddColumn('tblStates', 'timezone_id', 'BIGINT UNSIGNED', NULL, @required);
    CALL usp_AddColumn('tblStates', 'phone_code', 'VARCHAR(10)', NULL, @optional);
    CALL usp_AddColumn('tblStates', 'country_id', 'BIGINT UNSIGNED', NULL, @required);
END$$

DELIMITER ;

CALL usp_CreateColumns_tblStates();
DROP PROCEDURE usp_CreateColumns_tblStates;