DELIMITER $$

DROP PROCEDURE IF EXISTS usp_StoreOtp$$

-- =============================================
-- usp_StoreOtp
-- Stores a new One-Time Password (OTP) for a given sender.
--
-- Parameters:
--   in_value     - The OTP value to store.
--   in_recipient    - The recipient's email address.
--   in_recipient_id   - Optional: The recipient's identifier.
-- =============================================
CREATE PROCEDURE usp_StoreOtp(
    in_value VARCHAR(255),
    in_recipient VARCHAR(255),
    in_recipient_id BIGINT UNSIGNED
)
proc_label:BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        DECLARE v_error_message VARCHAR(255);
        GET DIAGNOSTICS CONDITION 1 v_error_message = MESSAGE_TEXT;
        ROLLBACK;
        SELECT NULL AS id, v_error_message AS message;
    END;

    IF in_value IS NULL OR TRIM(in_value) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Value is required.';
    END IF;

    IF in_recipient IS NULL OR TRIM(in_recipient) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Recipient is required.';
    END IF;

    START TRANSACTION;

    DELETE FROM tblOtp
    WHERE recipient = in_recipient;

    INSERT INTO tblOtp (recipient_id, value, recipient)
    VALUES (in_recipient_id, in_value, in_recipient);

    COMMIT;

    SELECT LAST_INSERT_ID() AS id, 'Success' AS message;

END$$

DELIMITER ;

SELECT 'usp_StoreOtp created successfully.' AS message;