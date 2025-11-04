DELIMITER $$

CREATE PROCEDURE usp_CreateColumns_tblOtp()
BEGIN
    DECLARE v_required BOOLEAN DEFAULT TRUE;
    DECLARE v_optional BOOLEAN DEFAULT FALSE;

    CALL usp_AddColumn('tblOtp', 'user_id', 'BIGINT UNSIGNED', NULL, v_required);
    CALL usp_AddColumn('tblOtp', 'value', 'VARCHAR(255)', NULL, v_required);
    CALL usp_AddColumn('tblOtp', 'sender', 'VARCHAR(255)', NULL, v_required);
    CALL usp_DropColumn('tblOtp', 'created_by');
    CALL usp_DropColumn('tblOtp', 'updated_by');
END$$

DELIMITER ;

CALL usp_CreateColumns_tblOtp();
DROP PROCEDURE usp_CreateColumns_tblOtp;