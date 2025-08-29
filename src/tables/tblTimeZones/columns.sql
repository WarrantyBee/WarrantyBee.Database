CALL usp_AddColumn('tblTimeZones', 'name', 'VARCHAR(100)', NULL, TRUE);
CALL usp_AddColumn('tblTimeZones', 'abbreviation', 'VARCHAR(10)', NULL, FALSE);
CALL usp_AddColumn('tblTimeZones', 'utc_offset_minutes', 'SMALLINT', NULL, TRUE);
CALL usp_AddColumn('tblTimeZones', 'observes_dst', 'BOOLEAN', '0', TRUE);
CALL usp_AddColumn('tblTimeZones', 'current_offset_minutes', 'SMALLINT', NULL, FALSE);