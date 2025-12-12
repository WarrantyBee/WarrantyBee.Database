DELIMITER $$

DROP TRIGGER IF EXISTS trg_BeforeInsert_tblAdminUsers$$

CREATE TRIGGER trg_BeforeInsert_tblAdminUsers
BEFORE INSERT ON tblAdminUsers
FOR EACH ROW
BEGIN
  SET NEW.internal_id = UUID_TO_BIN(UUID());
  SET NEW.void = 0;
  SET NEW.created_at = UTC_TIMESTAMP();
END;
$$

DELIMITER ;

SELECT 'trg_BeforeInsert_tblAdminUsers created successfully.' AS message;