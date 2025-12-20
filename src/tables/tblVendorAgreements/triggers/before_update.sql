DELIMITER $$

DROP TRIGGER IF EXISTS trg_BeforeUpdate_tblVendorAgreements$$

CREATE TRIGGER trg_BeforeUpdate_tblVendorAgreements
BEFORE UPDATE ON tblVendorAgreements
FOR EACH ROW
BEGIN
  SET NEW.updated_at = UTC_TIMESTAMP();
END;
$$

DELIMITER ;

SELECT 'trg_BeforeUpdate_tblVendorAgreements created successfully.' AS message;
