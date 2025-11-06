DELIMITER $$

DROP TRIGGER IF EXISTS trg_BeforeInsert_tblOtp$$

CREATE TRIGGER trg_BeforeInsert_tblOtp
BEFORE INSERT ON tblOtp
FOR EACH ROW
BEGIN
  DECLARE v_current_timestamp DATETIME;
  SET v_current_timestamp = UTC_TIMESTAMP();

  SET NEW.internal_id = UUID_TO_BIN(UUID());
  SET NEW.created_at = v_current_timestamp;
  SET NEW.void = 0;

  DELETE FROM tblOtp
  WHERE recipient = NEW.recipient;
END;
$$

DELIMITER ;

SELECT 'trg_BeforeInsert_tblOtp created successfully.' AS message;