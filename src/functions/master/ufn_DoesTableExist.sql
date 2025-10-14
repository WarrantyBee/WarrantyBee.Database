DELIMITER $$
DROP FUNCTION IF EXISTS ufn_DoesTableExist$$

-- =============================================
-- ufn_DoesTableExist
-- Checks if a specific table exists within the current database.
--
-- Parameters:
--   in_table_name - The name of the table to check for existence.
--
-- Returns:
--   TRUE if the table exists in the current database, otherwise FALSE.
--
-- Notes:
--   - Returns FALSE if an error occurs during execution.
--   - The function is deterministic and only checks in the current database.
-- =============================================

CREATE FUNCTION ufn_DoesTableExist(in_table_name VARCHAR(64))
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    -- Variable to store existence result
    DECLARE v_exists BOOLEAN DEFAULT FALSE;

    -- If any SQL exception occurs, set result to FALSE
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        SET v_exists = FALSE;

    -- Check for the table in information_schema.tables
    SELECT TRUE
    INTO v_exists
    FROM information_schema.tables
    WHERE table_schema = DATABASE()
      AND table_name = in_table_name
    LIMIT 1;

    -- Return TRUE if found, otherwise FALSE
    RETURN v_exists;
END$$

DELIMITER ;

SELECT 'ufn_DoesTableExist created successfully.' AS message;
