DELIMITER $$

DROP TRIGGER IF EXISTS trg_BeforeUpdate_tblCountries$$

CREATE TRIGGER trg_BeforeUpdate_tblCountries
BEFORE UPDATE ON tblCountries
FOR EACH ROW
BEGIN
  SET NEW.updated_at = UTC_TIMESTAMP();
END;
$$

DELIMITER ;

SELECT 'trg_BeforeUpdate_tblCountries created successfully.' AS message;
