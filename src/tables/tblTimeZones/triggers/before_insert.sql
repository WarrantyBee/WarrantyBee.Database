DELIMITER $$

DROP TRIGGER IF EXISTS trg_BeforeInsert_tblTimeZones$$

CREATE TRIGGER trg_BeforeInsert_tblTimeZones
BEFORE INSERT ON tblTimeZones
FOR EACH ROW
BEGIN
  SET NEW.internal_id = UUID_TO_BIN(UUID());
  SET NEW.created_at = UTC_TIMESTAMP();
  SET NEW.void = 0;
END;
$$

DELIMITER ;

SELECT 'trg_BeforeInsert_tblTimeZones created successfully.' AS message;