DELIMITER $$

DROP TRIGGER IF EXISTS trg_BeforeUpdate_tblCountries$$

CREATE TRIGGER trg_BeforeUpdate_tblCountries
BEFORE UPDATE ON tblCountries
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
  SET NEW.updated_at = UTC_TIMESTAMP();
END;
$$

DELIMITER ;

SELECT 'trg_BeforeUpdate_tblCountries created successfully.' AS message;
