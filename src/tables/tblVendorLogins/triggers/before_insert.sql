DELIMITER $$

DROP TRIGGER IF EXISTS trg_BeforeInsert_tblVendorLogins$$

CREATE TRIGGER trg_BeforeInsert_tblVendorLogins
BEFORE INSERT ON tblVendorLogins
FOR EACH ROW
BEGIN
  SET NEW.internal_id = UUID_TO_BIN(UUID());
  SET NEW.void = 0;
  SET NEW.created_at = UTC_TIMESTAMP();
END;
$$

DELIMITER ;

SELECT 'trg_BeforeInsert_tblVendorLogins created successfully.' AS message;