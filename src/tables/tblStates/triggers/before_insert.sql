DELIMITER $$

DROP TRIGGER IF EXISTS trg_BeforeInsert_tblStates$$

CREATE TRIGGER trg_BeforeInsert_tblStates
BEFORE INSERT ON tblStates
FOR EACH ROW
BEGIN
  IF NOT (NEW.phone_code IS NULL OR NEW.phone_code REGEXP '^\\+[0-9]+$') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid phone_code: must be null or start with + followed by digits.';
  END IF;
  SET NEW.internal_id = UUID_TO_BIN(UUID());
  SET NEW.created_at = UTC_TIMESTAMP();
  SET NEW.void = 0;
END;
$$

DELIMITER ;

SELECT 'trg_BeforeInsert_tblStates created successfully.' AS message;