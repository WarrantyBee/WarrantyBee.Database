DELIMITER $$

DROP TRIGGER IF EXISTS trg_BeforeUpdate_tblPermissions$$

CREATE TRIGGER trg_BeforeUpdate_tblPermissions
BEFORE UPDATE ON tblPermissions
FOR EACH ROW
BEGIN
  SET NEW.updated_at = UTC_TIMESTAMP();
END;
$$

DELIMITER ;

SELECT 'trg_BeforeUpdate_tblPermissions created successfully.' AS message;
