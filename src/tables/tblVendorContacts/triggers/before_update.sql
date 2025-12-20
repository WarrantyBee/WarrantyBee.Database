DELIMITER $$

DROP TRIGGER IF EXISTS trg_BeforeUpdate_tblVendorContacts$$

CREATE TRIGGER trg_BeforeUpdate_tblVendorContacts
BEFORE UPDATE ON tblVendorContacts
FOR EACH ROW
BEGIN
  SET NEW.updated_at = UTC_TIMESTAMP();
END;
$$

DELIMITER ;

SELECT 'trg_BeforeUpdate_tblVendorContacts created successfully.' AS message;
