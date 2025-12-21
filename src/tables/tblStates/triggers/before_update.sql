DELIMITER $$

DROP TRIGGER IF EXISTS trg_BeforeUpdate_tblStates$$

CREATE TRIGGER trg_BeforeUpdate_tblStates
BEFORE UPDATE ON tblStates
FOR EACH ROW
BEGIN
  IF NOT (NEW.phone_code IS NULL OR NEW.phone_code REGEXP '^\\+[0-9]+$') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid phone_code: must be null or start with + followed by digits.';
  END IF;
  SET NEW.updated_at = UTC_TIMESTAMP();
END;
$$

DELIMITER ;

SELECT 'trg_BeforeUpdate_tblStates created successfully.' AS message;
