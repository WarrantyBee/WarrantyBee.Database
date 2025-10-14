DELIMITER $$
DROP FUNCTION IF EXISTS ufn_DoesColumnExist$$

-- =============================================
-- ufn_DoesColumnExist
-- Checks if a specific column exists in a given table within the current database.
--
-- Parameters:
--   in_table_name   - The name of the table to check.
--   in_column_name  - The name of the column to check for existence.
--
-- Returns:
--   TRUE if the column exists in the specified table, otherwise FALSE.
--
-- Notes:
--   - Returns FALSE if an error occurs during execution.
--   - The function is deterministic and only checks in the current database.
-- =============================================

CREATE FUNCTION ufn_DoesColumnExist(
    in_table_name VARCHAR(64),
    in_column_name VARCHAR(64)
)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    -- Variable to store existence result
    DECLARE v_exists BOOLEAN DEFAULT FALSE;

    -- If any SQL exception occurs, set result to FALSE
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        SET v_exists = FALSE;

    -- Check for the column in information_schema.columns
    SELECT TRUE
    INTO v_exists
    FROM information_schema.columns
    WHERE table_schema = DATABASE()
      AND table_name = in_table_name
      AND column_name = in_column_name
    LIMIT 1;

    -- Return TRUE if found, otherwise FALSE
    RETURN v_exists;
END$$

DELIMITER ;

SELECT 'ufn_DoesColumnExist created successfully.' AS message;