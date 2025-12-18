DROP PROCEDURE IF EXISTS usp_CreateColumns_tblVendors;
DELIMITER $$

CREATE PROCEDURE usp_CreateColumns_tblVendors()
BEGIN
    DECLARE v_required BOOLEAN DEFAULT TRUE;
    DECLARE v_optional BOOLEAN DEFAULT FALSE;

    CALL usp_AddColumn('tblVendors', 'name', 'VARCHAR(128)', NULL, v_required);
    CALL usp_AddColumn('tblVendors', 'legal_name', 'VARCHAR(255)', NULL, v_optional);
    CALL usp_AddColumn('tblVendors', 'code', 'VARCHAR(32)', NULL, v_required);
    CALL usp_AddColumn('tblVendors', 'type', 'TINYINT', NULL, v_required);
    CALL usp_AddColumn('tblVendors', 'primary_email', 'VARCHAR(255)', NULL, v_required);
    CALL usp_AddColumn('tblVendors', 'primary_phone_code', 'VARCHAR(8)', NULL, v_required);
    CALL usp_AddColumn('tblVendors', 'primary_phone_number', 'VARCHAR(15)', NULL, v_required);
    CALL usp_AddColumn('tblVendors', 'website', 'VARCHAR(255)', NULL, v_optional);
    CALL usp_AddColumn('tblVendors', 'support_email', 'VARCHAR(255)', NULL, v_required);
    CALL usp_AddColumn('tblVendors', 'registration_number', 'VARCHAR(64)', NULL, v_required);
    CALL usp_AddColumn('tblVendors', 'registration_type', 'TINYINT', NULL, v_required);
    CALL usp_AddColumn('tblVendors', 'tax_identifier', 'VARCHAR(64)', NULL, v_required);
    CALL usp_AddColumn('tblVendors', 'tax_country_id', 'BIGINT UNSIGNED', NULL, v_required);
    CALL usp_AddColumn('tblVendors', 'tax_verified_at', 'TIMESTAMP', NULL, v_optional);
    CALL usp_AddColumn('tblVendors', 'compliance_status', 'TINYINT', NULL, v_required);
    CALL usp_AddColumn('tblVendors', 'compliance_reason', 'VARCHAR(255)', NULL, v_optional);
    CALL usp_AddColumn('tblVendors', 'compliance_verified_at', 'TIMESTAMP', NULL, v_optional);
    CALL usp_AddColumn('tblVendors', 'compliance_verified_by', 'BIGINT UNSIGNED', NULL, v_optional);
    CALL usp_AddColumn('tblVendors', 'contract_reference', 'VARCHAR(164)', NULL, v_required);
    CALL usp_AddColumn('tblVendors', 'contract_start_date', 'TIMESTAMP', NULL, v_optional);
    CALL usp_AddColumn('tblVendors', 'contract_end_date', 'TIMESTAMP', NULL, v_optional);
    CALL usp_AddColumn('tblVendors', 'risk_level', 'TINYINT', NULL, v_required);
    CALL usp_AddColumn('tblVendors', 'risk_reason', 'VARCHAR(255)', NULL, v_optional);
    CALL usp_AddColumn('tblVendors', 'sanctions_check_status', 'TINYINT', NULL, v_required);
    CALL usp_AddColumn('tblVendors', 'sanctions_checked_at', 'TIMESTAMP', NULL, v_optional);
    CALL usp_AddColumn('tblVendors', 'status', 'TINYINT', NULL, v_required);
    CALL usp_AddColumn('tblVendors', 'verified', 'BOOLEAN', NULL, v_required);
END$$

DELIMITER ;

CALL usp_CreateColumns_tblVendors();
DROP PROCEDURE usp_CreateColumns_tblVendors;
