DELIMITER $$

DROP TRIGGER IF EXISTS trg_BeforeInsert_tblCountries$$

CREATE TRIGGER trg_BeforeInsert_tblCountries
BEFORE INSERT ON tblCountries
FOR EACH ROW
BEGIN
  IF NOT (NEW.iso2_code REGEXP '^[A-Z]{2}$') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid iso2_code: must be 2 uppercase letters.';
  END IF;
  IF NOT (NEW.iso3_code REGEXP '^[A-Z]{3}$') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid iso3_code: must be 3 uppercase letters.';
  END IF;
  IF NOT (NEW.numeric_code REGEXP '^[0-9]{3}$') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid numeric_code: must be 3 digits.';
  END IF;
  SET NEW.internal_id = UUID_TO_BIN(UUID());
  SET NEW.created_at = UTC_TIMESTAMP();
  SET NEW.void = 0;
END;
$$

DELIMITER ;

SELECT 'trg_BeforeInsert_tblCountries created successfully.' AS message;