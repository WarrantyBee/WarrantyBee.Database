DELIMITER $$

DROP TRIGGER IF EXISTS trg_BeforeInsert_tblCurrencies$$

CREATE TRIGGER trg_BeforeInsert_tblCurrencies
BEFORE INSERT ON tblCurrencies
FOR EACH ROW
BEGIN
  IF NOT (NEW.numeric_code IS NULL OR NEW.numeric_code REGEXP '^[0-9]{3}$') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid numeric_code: must be NULL or a 3-digit number.';
  END IF;
  SET NEW.internal_id = UUID_TO_BIN(UUID());
  SET NEW.created_at = UTC_TIMESTAMP();
  SET NEW.void = 0;
END;
$$

DELIMITER ;

SELECT 'trg_BeforeInsert_tblCurrencies created successfully.' AS message;