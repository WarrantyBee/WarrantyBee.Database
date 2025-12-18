DELIMITER $$

DROP TRIGGER IF EXISTS trg_BeforeUpdate_tblVendorSettings$$

CREATE TRIGGER trg_BeforeUpdate_tblVendorSettings
BEFORE UPDATE ON tblVendorSettings
FOR EACH ROW
BEGIN
  SET NEW.updated_at = UTC_TIMESTAMP();
END;
$$

DELIMITER ;

SELECT 'trg_BeforeUpdate_tblVendorSettings created successfully.' AS message;
