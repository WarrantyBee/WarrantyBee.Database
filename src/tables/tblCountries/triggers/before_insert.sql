DELIMITER $$

DROP TRIGGER IF EXISTS trg_BeforeInsert_tblCountries$$

CREATE TRIGGER trg_BeforeInsert_tblCountries
BEFORE INSERT ON tblCountries
FOR EACH ROW
BEGIN
  SET NEW.internal_id = UUID_TO_BIN(UUID());
  SET NEW.created_at = UTC_TIMESTAMP();
END;
$$

DELIMITER ;

SELECT 'trg_BeforeInsert_tblCountries created successfully.' AS message;