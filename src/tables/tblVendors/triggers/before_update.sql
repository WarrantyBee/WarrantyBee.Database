DELIMITER $$

DROP TRIGGER IF EXISTS trg_BeforeUpdate_tblVendors$$

CREATE TRIGGER trg_BeforeUpdate_tblVendors
BEFORE UPDATE ON tblVendors
FOR EACH ROW
BEGIN
  SET NEW.updated_at = UTC_TIMESTAMP();
END;
$$

DELIMITER ;

SELECT 'trg_BeforeUpdate_tblVendors created successfully.' AS message;
