DELIMITER $$
DROP PROCEDURE IF EXISTS usp_GetOtp$$

CREATE PROCEDURE usp_GetOtp(
    IN in_recipient VARCHAR(255),
    IN in_type TINYINT
)
proc_label:BEGIN
    DECLARE v_active BOOLEAN DEFAULT FALSE;
    DECLARE v_expired BOOLEAN DEFAULT TRUE;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        DECLARE v_error_message VARCHAR(255);
        GET DIAGNOSTICS CONDITION 1 v_error_message = MESSAGE_TEXT;
        SELECT 1 AS status, v_error_message AS message;
    END;

    IF in_recipient IS NULL OR TRIM(in_recipient) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Recipient must be provided.';
    END IF;

    IF in_type IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Type must be provided.';
    END IF;

    SELECT 0 AS status, 'Success' AS message;

    SELECT
        id,
        value,
        recipient,
        recipient_id,
        `type`
    FROM
        tblOtp
    WHERE
        recipient = in_recipient AND
        `type` = in_type AND
        NOW() BETWEEN o.created_at AND
        created_at + INTERVAL 1 MINUTE AND
        void = v_active
    ORDER BY
        created_at DESC
    LIMIT 1;

    UPDATE tblOtp
    SET void = v_expired
    WHERE recipient = in_recipient
    AND `type` = in_type;
END$$

DELIMITER ;

SELECT 'usp_GetOtp created successfully.' AS message;
