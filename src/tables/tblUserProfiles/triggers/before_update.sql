DELIMITER $$

DROP TRIGGER IF EXISTS trg_BeforeUpdate_tblUserProfiles$$

CREATE TRIGGER trg_BeforeUpdate_tblUserProfiles
BEFORE UPDATE ON tblUserProfiles
FOR EACH ROW
BEGIN
  SET NEW.updated_at = UTC_TIMESTAMP();

  IF NEW.updated_by IS NULL THEN
    SET NEW.updated_by = OLD.updated_by;
  END IF;
END;
$$

DELIMITER ;

SELECT 'trg_BeforeUpdate_tblUserProfiles created successfully.' AS message;
