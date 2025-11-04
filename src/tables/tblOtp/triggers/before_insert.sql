DELIMITER $$

DROP TRIGGER IF EXISTS trg_BeforeInsert_tblOtp$$

CREATE TRIGGER trg_BeforeInsert_tblOtp
BEFORE INSERT ON tblOtp
FOR EACH ROW
BEGIN
  SET NEW.internal_id = UUID_TO_BIN(UUID());
  SET NEW.created_at = UTC_TIMESTAMP();
  SET NEW.void = 0;

  UPDATE tblOtp
  SET void = 1
  WHERE sender = NEW.sender;
END;
$$

DELIMITER ;

SELECT 'trg_BeforeInsert_tblOtp created successfully.' AS message;