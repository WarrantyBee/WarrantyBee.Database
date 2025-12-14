DELIMITER $$

DROP TRIGGER IF EXISTS trg_BeforeUpdate_tblCurrencies$$

CREATE TRIGGER trg_BeforeUpdate_tblCurrencies
BEFORE UPDATE ON tblCurrencies
FOR EACH ROW
BEGIN
  IF NOT (NEW.numeric_code IS NULL OR NEW.numeric_code REGEXP '^[0-9]{3}$') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid numeric_code: must be NULL or a 3-digit number.';
  END IF;
  SET NEW.updated_at = UTC_TIMESTAMP();
END;
$$

DELIMITER ;

SELECT 'trg_BeforeUpdate_tblCurrencies created successfully.' AS message;
