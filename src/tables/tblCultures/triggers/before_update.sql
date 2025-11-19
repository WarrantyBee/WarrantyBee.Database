DELIMITER $$

DROP TRIGGER IF EXISTS trg_BeforeUpdate_tblCultures$$

CREATE TRIGGER trg_BeforeUpdate_tblCultures
BEFORE UPDATE ON tblCultures
FOR EACH ROW
BEGIN
  SET NEW.updated_at = UTC_TIMESTAMP();
END;
$$

DELIMITER ;

SELECT 'trg_BeforeUpdate_tblCultures created successfully.' AS message;
