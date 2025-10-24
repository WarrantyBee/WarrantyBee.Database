DELIMITER $$

DROP TRIGGER IF EXISTS trg_BeforeUpdate_tblTimeZones$$

CREATE TRIGGER trg_BeforeUpdate_tblTimeZones
BEFORE UPDATE ON tblTimeZones
FOR EACH ROW
BEGIN
  SET NEW.updated_at = UTC_TIMESTAMP();
END;
$$

DELIMITER ;

SELECT 'trg_BeforeUpdate_tblTimeZones created successfully.' AS message;
