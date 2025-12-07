DELIMITER $$

DROP TRIGGER IF EXISTS trg_BeforeInsert_tblRolePermissions$$

CREATE TRIGGER trg_BeforeInsert_tblRolePermissions
BEFORE INSERT ON tblRolePermissions
FOR EACH ROW
BEGIN
  SET NEW.internal_id = UUID_TO_BIN(UUID());
  SET NEW.created_at = UTC_TIMESTAMP();
  SET NEW.void = 0;
END;
$$

DELIMITER ;

SELECT 'trg_BeforeInsert_tblRolePermissions created successfully.' AS message;