DELIMITER $$

CREATE PROCEDURE usp_CreateColumns_tblCountries()
BEGIN
    DECLARE @required BOOLEAN DEFAULT TRUE;
    DECLARE @optional BOOLEAN DEFAULT FALSE;

    CALL usp_AddColumn('tblCountries', 'iso2_code', 'CHAR(2)', NULL, @required);
    CALL usp_AddColumn('tblCountries', 'iso3_code', 'CHAR(3)', NULL, @required);
    CALL usp_AddColumn('tblCountries', 'numeric_code', 'CHAR(3)', NULL, @required);
    CALL usp_AddColumn('tblCountries', 'name', 'VARCHAR(100)', NULL, @required);
    CALL usp_AddColumn('tblCountries', 'official_name', 'VARCHAR(150)', NULL, @optional);
    CALL usp_AddColumn('tblCountries', 'capital', 'VARCHAR(100)', NULL, @optional);
    CALL usp_AddColumn('tblCountries', 'phone_code', 'VARCHAR(10)', NULL, @optional);
    CALL usp_AddColumn('tblCountries', 'currency_id', 'BIGINT UNSIGNED', NULL, @optional);
END$$

DELIMITER ;

CALL usp_CreateColumns_tblCountries();
DROP PROCEDURE usp_CreateColumns_tblCountries;