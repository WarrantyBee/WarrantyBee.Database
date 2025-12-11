DROP PROCEDURE IF EXISTS usp_CreateColumns_tblUsers;
DELIMITER $$

CREATE PROCEDURE usp_CreateColumns_tblUsers()
BEGIN
    DECLARE v_required BOOLEAN DEFAULT TRUE;
    DECLARE v_optional BOOLEAN DEFAULT FALSE;

    CALL usp_AddColumn('tblUsers', 'firstname', 'VARCHAR(128)', NULL, v_required);
    CALL usp_AddColumn('tblUsers', 'lastname', 'VARCHAR(128)', NULL, v_required);
    CALL usp_AddColumn('tblUsers', 'email', 'VARCHAR(255)', NULL, v_required);
    CALL usp_AddColumn('tblUsers', 'password', 'VARCHAR(255)', NULL, v_required);
    CALL usp_AddColumn('tblUsers', 'is_2fa_enabled', 'BOOLEAN', '0', v_required);
    CALL usp_AddColumn('tblUsers', 'login_token', 'VARCHAR(255)', NULL, v_optional);
    CALL usp_AddColumn('tblUsers', 'password_updated_at', 'TIMESTAMP', NULL, v_optional);
    CALL usp_AddColumn('tblUsers', 'accepted_tnc', 'BOOLEAN', NULL, v_required);
    CALL usp_AddColumn('tblUsers', 'accepted_pp', 'BOOLEAN', NULL, v_required);
    CALL usp_AddColumn('tblUsers', 'role_id', 'BIGINT UNSIGNED', NULL, v_required);
    CALL usp_AddColumn('tblUsers', 'auth_provider', 'TINYINT', '1', v_required);
    CALL usp_AddColumn('tblUsers', 'auth_provider_user_id', 'VARCHAR(50)', NULL, v_optional);
    CALL usp_DropColumn('tblUsers', 'created_by');
    CALL usp_DropColumn('tblUsers', 'updated_by');
END$$

DELIMITER ;

CALL usp_CreateColumns_tblUsers();
DROP PROCEDURE usp_CreateColumns_tblUsers;