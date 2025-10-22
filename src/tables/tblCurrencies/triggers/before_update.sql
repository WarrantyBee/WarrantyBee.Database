DELIMITER $$

DROP TRIGGER IF EXISTS trg_BeforeUpdate_tblCurrencies$$

CREATE TRIGGER trg_BeforeUpdate_tblCurrencies
BEFORE UPDATE ON tblCurrencies
FOR EACH ROW
BEGIN
  SET NEW.updated_at = UTC_TIMESTAMP();
END;
$$

DELIMITER ;

SELECT 'trg_BeforeUpdate_tblCurrencies created successfully.' AS message;
