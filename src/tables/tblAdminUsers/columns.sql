DROP PROCEDURE IF EXISTS usp_CreateColumns_tblAdminUsers;
DELIMITER $$

CREATE PROCEDURE usp_CreateColumns_tblAdminUsers()
BEGIN
    DECLARE v_required BOOLEAN DEFAULT TRUE;
    DECLARE v_optional BOOLEAN DEFAULT FALSE;

CALL usp_AddColumn('tblAdminUsers', 'firstname', 'VARCHAR(128)', NULL, v_required);
CALL usp_AddColumn('tblAdminUsers', 'lastname', 'VARCHAR(128)', NULL, v_required);
CALL usp_AddColumn('tblAdminUsers', 'email', 'VARCHAR(255)', NULL, v_required);
CALL usp_AddColumn('tblAdminUsers', 'password', 'VARCHAR(255)', NULL, v_required);
CALL usp_AddColumn('tblAdminUsers', 'is_2fa_enabled', 'BOOLEAN', '1', v_required);
CALL usp_AddColumn('tblAdminUsers', 'permissions', 'VARCHAR(1024)', NULL, v_required);
CALL usp_DropColumn('tblAdminUsers', 'created_by');
CALL usp_DropColumn('tblAdminUsers', 'updated_by');

END$$

DELIMITER ;

CALL usp_CreateColumns_tblAdminUsers();
DROP PROCEDURE usp_CreateColumns_tblAdminUsers;