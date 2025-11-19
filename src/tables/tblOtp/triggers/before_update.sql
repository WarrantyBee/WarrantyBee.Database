DELIMITER $$

DROP TRIGGER IF EXISTS trg_BeforeUpdate_tblOtp$$

CREATE TRIGGER trg_BeforeUpdate_tblOtp
BEFORE UPDATE ON tblOtp
FOR EACH ROW
BEGIN
  SET NEW.updated_at = UTC_TIMESTAMP();
END;
$$

DELIMITER ;

SELECT 'trg_BeforeUpdate_tblOtp created successfully.' AS message;
