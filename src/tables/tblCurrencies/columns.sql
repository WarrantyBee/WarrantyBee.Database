DELIMITER $$

CREATE PROCEDURE usp_CreateColumns_tblCurrencies()
BEGIN
    DECLARE v_required BOOLEAN DEFAULT TRUE;
    DECLARE v_optional BOOLEAN DEFAULT FALSE;

    CALL usp_AddColumn('tblCurrencies', 'iso_code', 'CHAR(3)', NULL, v_required);
    CALL usp_AddColumn('tblCurrencies', 'numeric_code', 'CHAR(3)', NULL, v_optional);
    CALL usp_AddColumn('tblCurrencies', 'name', 'VARCHAR(100)', NULL, v_required);
    CALL usp_AddColumn('tblCurrencies', 'symbol', 'VARCHAR(10)', NULL, v_required);
    CALL usp_AddColumn('tblCurrencies', 'minor_unit', 'TINYINT UNSIGNED', '2', v_required);
    CALL usp_DropColumn('tblCurrencies', 'created_by');
    CALL usp_DropColumn('tblCurrencies', 'updated_by');
END$$

DELIMITER ;

CALL usp_CreateColumns_tblCurrencies();
DROP PROCEDURE usp_CreateColumns_tblCurrencies;