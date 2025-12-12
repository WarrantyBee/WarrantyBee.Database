DELIMITER $$

DROP TRIGGER IF EXISTS trg_BeforeUpdate_tblRolePermissions$$

CREATE TRIGGER trg_BeforeUpdate_tblRolePermissions
BEFORE UPDATE ON tblRolePermissions
FOR EACH ROW
BEGIN
  SET NEW.updated_at = UTC_TIMESTAMP();
END;
$$

DELIMITER ;

SELECT 'trg_BeforeUpdate_tblRolePermissions created successfully.' AS message;
