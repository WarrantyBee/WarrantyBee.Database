DELIMITER $$

CREATE PROCEDURE usp_CreateColumns_tblCountries()
BEGIN
    DECLARE v_required BOOLEAN DEFAULT TRUE;
    DECLARE v_optional BOOLEAN DEFAULT FALSE;

    CALL usp_AddColumn('tblCountries', 'iso2_code', 'CHAR(2)', NULL, v_required);
    CALL usp_AddColumn('tblCountries', 'iso3_code', 'CHAR(3)', NULL, v_required);
    CALL usp_AddColumn('tblCountries', 'numeric_code', 'CHAR(3)', NULL, v_required);
    CALL usp_AddColumn('tblCountries', 'name', 'VARCHAR(100)', NULL, v_required);
    CALL usp_AddColumn('tblCountries', 'official_name', 'VARCHAR(150)', NULL, v_optional);
    CALL usp_AddColumn('tblCountries', 'capital', 'VARCHAR(100)', NULL, v_optional);
    CALL usp_AddColumn('tblCountries', 'phone_code', 'VARCHAR(10)', NULL, v_optional);
    CALL usp_AddColumn('tblCountries', 'currency_id', 'BIGINT UNSIGNED', NULL, v_optional);
END$$

DELIMITER ;

CALL usp_CreateColumns_tblCountries();
DROP PROCEDURE usp_CreateColumns_tblCountries;