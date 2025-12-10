DROP PROCEDURE IF EXISTS usp_CreateColumns_tblVendorLogins;
DELIMITER $$

CREATE PROCEDURE usp_CreateColumns_tblVendorLogins()
BEGIN
    DECLARE v_required BOOLEAN DEFAULT TRUE;
    DECLARE v_optional BOOLEAN DEFAULT FALSE;

    CALL usp_AddColumn('tblVendorLogins', 'vendor_id', 'VARCHAR(255)', NULL, v_required);
    CALL usp_AddColumn('tblVendorLogins', 'user_id', 'VARCHAR(255)', NULL, v_required);
    
END$$

DELIMITER ;

CALL usp_CreateColumns_tblVendorLogins();
DROP PROCEDURE usp_CreateColumns_tblVendorLogins;