DELIMITER $$

DROP TRIGGER IF EXISTS trg_BeforeInsert_tblVendors$$

CREATE TRIGGER trg_BeforeInsert_tblVendors
BEFORE INSERT ON tblVendors
FOR EACH ROW
BEGIN
  SET NEW.internal_id = UUID_TO_BIN(UUID());
  SET NEW.void = 0;
  SET NEW.created_at = UTC_TIMESTAMP();
END;
$$

DELIMITER ;

SELECT 'trg_BeforeInsert_tblVendors created successfully.' AS message;