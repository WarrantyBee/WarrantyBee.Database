DELIMITER $$

DROP TRIGGER IF EXISTS trg_BeforeUpdate_tblLanguages$$

CREATE TRIGGER trg_BeforeUpdate_tblLanguages
BEFORE UPDATE ON tblLanguages
FOR EACH ROW
BEGIN
  SET NEW.updated_at = UTC_TIMESTAMP();
END;
$$

DELIMITER ;

SELECT 'trg_BeforeUpdate_tblLanguages created successfully.' AS message;
