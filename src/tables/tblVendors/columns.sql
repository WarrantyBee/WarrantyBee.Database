DROP PROCEDURE IF EXISTS usp_CreateColumns_tblVendors;
DELIMITER $$

CREATE PROCEDURE usp_CreateColumns_tblVendors()
BEGIN
    DECLARE v_required BOOLEAN DEFAULT TRUE;
    DECLARE v_optional BOOLEAN DEFAULT FALSE;

    CALL usp_AddColumn('tblVendors', 'name', 'VARCHAR(255)', NULL, v_required);
    CALL usp_AddColumn('tblVendors', 'address_line_1', 'VARCHAR(255)', NULL, v_required);
    CALL usp_AddColumn('tblVendors', 'address_line_2', 'VARCHAR(255)', NULL, v_optional);
    CALL usp_AddColumn('tblVendors', 'city', 'VARCHAR(128)', NULL, v_required);
    CALL usp_AddColumn('tblVendors', 'region_id', 'BIGINT UNSIGNED', NULL, v_required);
    CALL usp_AddColumn('tblVendors', 'country_id', 'BIGINT UNSIGNED', NULL, v_required);
    CALL usp_AddColumn('tblVendors', 'postal_code', 'VARCHAR(20)', NULL, v_required);
    CALL usp_AddColumn('tblVendors', 'phone_number', 'VARCHAR(20)', NULL, v_required);
    CALL usp_AddColumn('tblVendors', 'email', 'VARCHAR(255)', NULL, v_required);
    CALL usp_AddColumn('tblVendors', 'website', 'VARCHAR(255)', NULL, v_optional);
    CALL usp_AddColumn('tblVendors', 'map_url', 'VARCHAR(2048)', NULL, v_required);
    CALL usp_AddColumn('tblVendors', 'latitude', 'DECIMAL(10, 8)', NULL, v_required);
    CALL usp_AddColumn('tblVendors', 'longitude', 'DECIMAL(11, 8)', NULL, v_required);
END$$

DELIMITER ;

CALL usp_CreateColumns_tblVendors();
DROP PROCEDURE usp_CreateColumns_tblVendors;

