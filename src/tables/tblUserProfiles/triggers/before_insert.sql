DELIMITER $$

DROP TRIGGER IF EXISTS trg_BeforeInsert_tblUserProfiles$$

CREATE TRIGGER trg_BeforeInsert_tblUserProfiles
BEFORE INSERT ON tblUserProfiles
FOR EACH ROW
BEGIN
  SET NEW.internal_id = UUID_TO_BIN(UUID());
  SET NEW.created_at = UTC_TIMESTAMP();
END;
$$

DELIMITER ;

SELECT 'trg_BeforeInsert_tblUserProfiles created successfully.' AS message;