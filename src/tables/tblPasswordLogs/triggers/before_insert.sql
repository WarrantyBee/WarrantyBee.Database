DELIMITER $$

DROP TRIGGER IF EXISTS trg_BeforeInsert_tblPasswordLogs$$

CREATE TRIGGER trg_BeforeInsert_tblPasswordLogs
BEFORE INSERT ON tblPasswordLogs
FOR EACH ROW
BEGIN
  SET NEW.internal_id = UUID_TO_BIN(UUID());
  SET NEW.created_at = UTC_TIMESTAMP();
  SET NEW.void = 0;
  
  IF NEW.created_by IS NULL THEN
    SET NEW.created_by = NEW.user_id;
  END IF;
END;
$$

DELIMITER ;

SELECT 'trg_BeforeInsert_tblPasswordLogs created successfully.' AS message;