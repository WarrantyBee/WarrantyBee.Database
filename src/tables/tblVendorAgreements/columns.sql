DROP PROCEDURE IF EXISTS usp_CreateColumns_tblVendorAgreements;
DELIMITER $$

CREATE PROCEDURE usp_CreateColumns_tblVendorAgreements()
BEGIN
    DECLARE v_required BOOLEAN DEFAULT TRUE;
    DECLARE v_optional BOOLEAN DEFAULT FALSE;
   
    CALL usp_AddColumn('tblVendorAgreements', 'vendor_id', 'BIGINT UNSIGNED', NULL, v_required);
    CALL usp_AddColumn('tblVendorAgreements', 'type', 'TINYINT', NULL, v_required);
    CALL usp_AddColumn('tblVendorAgreements', 'version', 'VARCHAR(10)', NULL, v_required);
    CALL usp_AddColumn('tblVendorAgreements', 'accepted', 'BOOLEAN', '0', v_required);
    CALL usp_AddColumn('tblVendorAgreements', 'accepted_at', 'DATETIME', NULL, v_optional);
    CALL usp_AddColumn('tblVendorAgreements', 'document_url', 'VARCHAR(512)', NULL, v_required);
    CALL usp_DropColumn('tblVendorAgreements', 'created_by');
    CALL usp_DropColumn('tblVendorAgreements', 'updated_by');
END$$

DELIMITER ;

CALL usp_CreateColumns_tblVendorAgreements();
DROP PROCEDURE usp_CreateColumns_tblVendorAgreements;