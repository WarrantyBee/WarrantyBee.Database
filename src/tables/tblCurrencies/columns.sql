DELIMITER $$

CREATE PROCEDURE usp_CreateColumns_tblCurrencies()
BEGIN
    DECLARE @required BOOLEAN DEFAULT TRUE;
    DECLARE @optional BOOLEAN DEFAULT FALSE;

    CALL usp_AddColumn('tblCurrencies', 'iso_code', 'CHAR(3)', NULL, @required);
    CALL usp_AddColumn('tblCurrencies', 'numeric_code', 'CHAR(3)', NULL, @optional);
    CALL usp_AddColumn('tblCurrencies', 'name', 'VARCHAR(100)', NULL, @required);
    CALL usp_AddColumn('tblCurrencies', 'symbol', 'VARCHAR(10)', NULL, @required);
    CALL usp_AddColumn('tblCurrencies', 'minor_unit', 'TINYINT UNSIGNED', '2', @required);
END$$

DELIMITER ;

CALL usp_CreateColumns_tblCurrencies();
DROP PROCEDURE usp_CreateColumns_tblCurrencies;