DELIMITER $$
DROP PROCEDURE IF EXISTS usp_DropColumn$$

-- =============================================
-- usp_DropColumn
-- Drops a column from a table if it exists.
--
-- Parameters:
--   in_table_name   - The name of the table to alter.
--   in_column_name  - The name of the column to drop.
--
-- Usage:
--   CALL usp_DropColumn('tblExample', 'old_column');
--
-- Notes:
--   - Checks if the table and column exist before attempting to drop.
--   - Handles exceptions and prints messages for each execution flow.
--   - Always uses backticks for database objects.
-- =============================================

CREATE PROCEDURE usp_DropColumn(
    IN in_table_name VARCHAR(64),     -- Table name input
    IN in_column_name VARCHAR(64)     -- Column name input
)
BEGIN
    -- Exception handler: catches any SQL errors during execution
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Return failure message if an exception occurs
        SELECT CONCAT(
            'Failed to drop column `',
            in_column_name,
            '` from table `',
            in_table_name,
            '` due to an exception.'
        ) AS message;
    END;

    -- Check if table exists
    IF NOT ufn_DoesTableExist(in_table_name) THEN
        -- Inform user if table is missing
        SELECT CONCAT(
            'Table `',
            in_table_name,
            '` does not exist.'
        ) AS message;

    -- Check if column exists
    ELSEIF NOT ufn_DoesColumnExist(in_table_name, in_column_name) THEN
        -- Inform user if column is missing in the given table
        SELECT CONCAT(
            'Column `',
            in_column_name,
            '` does not exist in table `',
            in_table_name,
            '`.'
        ) AS message;

    ELSE
        -- Build dynamic SQL to drop the column
        SET @sql = CONCAT(
            'ALTER TABLE `', in_table_name, '` DROP COLUMN `', in_column_name, '`'
        );

        -- Prepare and execute the dynamic SQL
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        -- Success message after dropping the column
        SELECT CONCAT(
            'Column `',
            in_column_name,
            '` dropped successfully from table `',
            in_table_name,
            '`.'
        ) AS message;
    END IF;
END
$$

DELIMITER ;