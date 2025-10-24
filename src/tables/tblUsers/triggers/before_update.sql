DELIMITER $$

DROP TRIGGER IF EXISTS trg_BeforeUpdate_tblUsers$$

CREATE TRIGGER trg_BeforeUpdate_tblUsers
BEFORE UPDATE ON tblUsers
FOR EACH ROW
BEGIN
  SET NEW.updated_at = UTC_TIMESTAMP();
END;
$$

DELIMITER ;

SELECT 'trg_BeforeUpdate_tblUsers created successfully.' AS message;
