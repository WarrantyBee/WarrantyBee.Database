DROP PROCEDURE IF EXISTS usp_CreateColumns_tblTimeZones;
DELIMITER $$

CREATE PROCEDURE usp_CreateColumns_tblTimeZones()
BEGIN
    DECLARE v_required BOOLEAN DEFAULT TRUE;
    DECLARE v_optional BOOLEAN DEFAULT FALSE;

    CALL usp_AddColumn('tblTimeZones', 'name', 'VARCHAR(100)', NULL, v_required);
    CALL usp_AddColumn('tblTimeZones', 'abbreviation', 'VARCHAR(10)', NULL, v_optional);
    CALL usp_AddColumn('tblTimeZones', 'utc_offset_minutes', 'SMALLINT', NULL, v_required);
    CALL usp_AddColumn('tblTimeZones', 'observes_dst', 'BOOLEAN', '0', v_required);
    CALL usp_AddColumn('tblTimeZones', 'current_offset_minutes', 'SMALLINT', NULL, v_required);
    CALL usp_DropColumn('tblTimeZones', 'created_by');
    CALL usp_DropColumn('tblTimeZones', 'updated_by');
END$$

DELIMITER ;

CALL usp_CreateColumns_tblTimeZones();
DROP PROCEDURE usp_CreateColumns_tblTimeZones;