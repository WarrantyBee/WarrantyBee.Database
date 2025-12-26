DELIMITER $$

DROP TRIGGER IF EXISTS trg_BeforeUpdate_tblAdminUsers$$

CREATE TRIGGER trg_BeforeUpdate_tblAdminUsers
BEFORE UPDATE ON tblAdminUsers
FOR EACH ROW
BEGIN
  SET NEW.updated_at = UTC_TIMESTAMP();
END;
$$

DELIMITER ;

SELECT 'trg_BeforeUpdate_tblAdminUsers created successfully.' AS message;
