DELIMITER $$

DROP TRIGGER IF EXISTS trg_BeforeInsert_tblRoles$$

CREATE TRIGGER trg_BeforeInsert_tblRoles
BEFORE INSERT ON tblRoles
FOR EACH ROW
BEGIN
  SET NEW.internal_id = UUID_TO_BIN(UUID());
  SET NEW.created_at = UTC_TIMESTAMP();
  SET NEW.void = 0;
END;
$$

DELIMITER ;

SELECT 'trg_BeforeInsert_tblRoles created successfully.' AS message;