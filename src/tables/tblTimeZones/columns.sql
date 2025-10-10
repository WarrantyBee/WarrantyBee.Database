DELIMITER $$

CREATE PROCEDURE usp_CreateColumns_tblTimeZones()
BEGIN
    DECLARE @required BOOLEAN DEFAULT TRUE;
    DECLARE @optional BOOLEAN DEFAULT FALSE;

    CALL usp_AddColumn('tblTimeZones', 'name', 'VARCHAR(100)', NULL, @required);
    CALL usp_AddColumn('tblTimeZones', 'abbreviation', 'VARCHAR(10)', NULL, @optional);
    CALL usp_AddColumn('tblTimeZones', 'utc_offset_minutes', 'SMALLINT', NULL, @required);
    CALL usp_AddColumn('tblTimeZones', 'observes_dst', 'BOOLEAN', '0', @required);
    CALL usp_AddColumn('tblTimeZones', 'current_offset_minutes', 'SMALLINT', NULL, @required);
END$$

DELIMITER ;

CALL usp_CreateColumns_tblTimeZones();
DROP PROCEDURE usp_CreateColumns_tblTimeZones;