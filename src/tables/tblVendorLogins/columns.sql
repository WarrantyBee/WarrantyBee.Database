DROP PROCEDURE IF EXISTS usp_CreateColumns_tblVendorLogins;
DELIMITER $$

CREATE PROCEDURE usp_CreateColumns_tblVendorLogins()
BEGIN
    DECLARE v_required BOOLEAN DEFAULT TRUE;
    DECLARE v_optional BOOLEAN DEFAULT FALSE;

    CALL usp_AddColumn('tblVendorLogins', 'vendor_id', 'BIGINT UNSIGNED', NULL, v_required);
    CALL usp_AddColumn('tblVendorLogins', 'user_id', 'BIGINT UNSIGNED', NULL, v_required);
    CALL usp_DropColumn('tblVendors', 'created_by');
    CALL usp_DropColumn('tblVendors', 'updated_by');
    
END$$

DELIMITER ;

CALL usp_CreateColumns_tblVendorLogins();
DROP PROCEDURE usp_CreateColumns_tblVendorLogins;