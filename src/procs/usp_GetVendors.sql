DELIMITER $$
DROP PROCEDURE IF EXISTS usp_GetVendors$$

CREATE PROCEDURE usp_GetVendors(
    IN in_id BIGINT UNSIGNED,
    IN in_email VARCHAR(255)
)
proc_label:BEGIN
    DECLARE v_vendor_exists INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        DECLARE v_error_message VARCHAR(255);
        GET DIAGNOSTICS CONDITION 1 v_error_message = MESSAGE_TEXT;
        SELECT 1 AS status, v_error_message AS message;
    END;

    IF in_id IS NULL AND (in_email IS NULL OR TRIM(in_email) = '') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Either a vendor ID or an email must be provided.';
    END IF;

    SELECT COUNT(1) INTO v_vendor_exists
    FROM tblVendors v
    WHERE (in_id IS NOT NULL AND v.id = in_id) OR (in_email IS NOT NULL AND v.email = in_email);

    IF v_vendor_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vendor not found.';
    END IF;

    SELECT 0 AS status, 'Success' AS message;

    SELECT
        v.id,
        v.name,
        v.address,
        v.city,
        v.zip_code,
        v.phone_number,
        v.email,
        v.website,
        v.is_active,
        v.created_at,
        v.updated_at,
        c.id AS country_id,
        c.name AS country_name,
        c.iso3_code AS country_iso3,
        s.id AS state_id,
        s.name AS state_name,
        s.iso_code AS state_iso
    FROM
        tblVendors v
    LEFT JOIN tblCountries c ON v.country_id = c.id
    LEFT JOIN tblStates s ON v.state_id = s.id
    WHERE (in_id IS NOT NULL AND v.id = in_id)
    OR (in_email IS NOT NULL AND v.email = in_email)
    LIMIT 1;

END$$

DELIMITER ;

SELECT 'usp_GetVendors created successfully.' AS message;
