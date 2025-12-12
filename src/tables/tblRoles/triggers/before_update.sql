DELIMITER $$

DROP TRIGGER IF EXISTS trg_BeforeUpdate_tblRoles$$

CREATE TRIGGER trg_BeforeUpdate_tblRoles
BEFORE UPDATE ON tblRoles
FOR EACH ROW
BEGIN
  SET NEW.updated_at = UTC_TIMESTAMP();
END;
$$

DELIMITER ;

SELECT 'trg_BeforeUpdate_tblRoles created successfully.' AS message;
