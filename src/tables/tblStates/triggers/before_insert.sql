DELIMITER $$

DROP TRIGGER IF EXISTS trg_BeforeInsert_tblStates$$

CREATE TRIGGER trg_BeforeInsert_tblStates
BEFORE INSERT ON tblStates
FOR EACH ROW
BEGIN
  SET NEW.internal_id = UUID_TO_BIN(UUID());
  SET NEW.created_at = UTC_TIMESTAMP();
  SET NEW.void = 0;
END;
$$

DELIMITER ;

SELECT 'trg_BeforeInsert_tblStates created successfully.' AS message;