DELIMITER $$

CREATE PROCEDURE usp_CreateColumns_tblUsers()
BEGIN
    DECLARE v_required BOOLEAN DEFAULT TRUE;
    DECLARE v_optional BOOLEAN DEFAULT FALSE;

    CALL usp_AddColumn('tblUsers', 'firstname', 'VARCHAR(128)', NULL, v_required);
    CALL usp_AddColumn('tblUsers', 'lastname', 'VARCHAR(128)', NULL, v_required);
    CALL usp_AddColumn('tblUsers', 'email', 'VARCHAR(255)', NULL, v_required);
    CALL usp_AddColumn('tblUsers', 'password', 'VARCHAR(255)', NULL, v_required);
END$$

DELIMITER ;

CALL usp_CreateColumns_tblUsers();
DROP PROCEDURE usp_CreateColumns_tblUsers;