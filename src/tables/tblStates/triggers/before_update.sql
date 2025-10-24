DELIMITER $$

DROP TRIGGER IF EXISTS trg_BeforeUpdate_tblStates$$

CREATE TRIGGER trg_BeforeUpdate_tblStates
BEFORE UPDATE ON tblStates
FOR EACH ROW
BEGIN
  SET NEW.updated_at = UTC_TIMESTAMP();
END;
$$

DELIMITER ;

SELECT 'trg_BeforeUpdate_tblStates created successfully.' AS message;
