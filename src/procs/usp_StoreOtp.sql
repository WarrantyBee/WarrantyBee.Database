DELIMITER $$

DROP PROCEDURE IF EXISTS usp_StoreOtp$$

-- =============================================
-- usp_StoreOtp
-- Stores a new One-Time Password (OTP) for a given sender.
--
-- Parameters:
--   in_value     - The OTP value to store.
--   in_sender    - The sender's identifier (e.g., email or phone number).
--   in_user_id   - Optional: The user ID associated with this OTP.
-- =============================================
CREATE PROCEDURE usp_StoreOtp(
    in_value VARCHAR(255),
    in_sender VARCHAR(255),
    in_user_id BIGINT UNSIGNED
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

    IF in_sender IS NULL OR TRIM(in_sender) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Sender is required.';
    END IF;

    START TRANSACTION;

    INSERT INTO tblOtp (user_id, value, sender)
    VALUES (in_user_id, in_value, in_sender);

    COMMIT;

    SELECT LAST_INSERT_ID() AS id, 'Success' AS message;

END$$

DELIMITER ;

SELECT 'usp_StoreOtp created successfully.' AS message;