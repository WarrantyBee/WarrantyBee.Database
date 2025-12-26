DELIMITER $$

DROP TRIGGER IF EXISTS trg_BeforeUpdate_tblVendorLogins$$

CREATE TRIGGER trg_BeforeUpdate_tblVendorLogins
BEFORE UPDATE ON tblVendorLogins
FOR EACH ROW
BEGIN
  SET NEW.updated_at = UTC_TIMESTAMP();
END;
$$

DELIMITER ;

SELECT 'trg_BeforeUpdate_tblVendorLogins created successfully.' AS message;
