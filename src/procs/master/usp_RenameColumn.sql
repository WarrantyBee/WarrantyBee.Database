DELIMITER $$
DROP PROCEDURE IF EXISTS usp_RenameColumn$$

-- =============================================
-- usp_RenameColumn
-- Renames a column in a specified table.
--
-- Parameters:
--   in_table_name      - The name of the table to alter.
--   in_old_column_name - The current name of the column.
--   in_new_column_name - The new name for the column.
--
-- Usage:
--   CALL usp_RenameColumn('tblExample', 'old_name', 'new_name');
--
-- Notes:
--   - Checks if the table and old column exist before attempting to rename.
--   - Checks if the new column name already exists to prevent conflicts.
--   - Prints messages for every execution flow and handles exceptions.
-- =============================================

CREATE PROCEDURE usp_RenameColumn(
    IN in_table_name VARCHAR(64),
    IN in_old_column_name VARCHAR(64),
    IN in_new_column_name VARCHAR(64)
)
BEGIN
    -- Declare variables for dynamic SQL
    DECLARE v_sql VARCHAR(2000);

    -- Handle any SQL exception and print a custom message
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT CONCAT(
            'Column rename from ',
            in_old_column_name,
            ' to ',
            in_new_column_name,
            ' failed due to an exception.'
        ) AS message;
    END;

    -- Check if table exists
    IF NOT ufn_DoesTableExist(in_table_name) THEN
        SELECT CONCAT(
            'Column rename failed because table ',
            in_table_name,
            ' does not exist.'
        ) AS message;
    -- Check if old column exists
    ELSEIF NOT ufn_DoesColumnExist(in_table_name, in_old_column_name) THEN
        SELECT CONCAT(
            'Column rename failed because column ',
            in_old_column_name,
            ' does not exist in table ',
            in_table_name,
            '.'
        ) AS message;
    -- Check if new column name already exists
    ELSEIF ufn_DoesColumnExist(in_table_name, in_new_column_name) THEN
        SELECT CONCAT(
            'Column rename failed because column ',
            in_new_column_name,
            ' already exists in table ',
            in_table_name,
            '.'
        ) AS message;
    ELSE
        -- Start building the ALTER TABLE statement
        SET @sql = CONCAT(
            'ALTER TABLE ', in_table_name,
            ' RENAME COLUMN ', in_old_column_name, ' TO ', in_new_column_name
        );

        -- Execute the dynamic SQL to rename the column
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SELECT CONCAT(
            'Column ',
            in_old_column_name,
            ' renamed successfully to ',
            in_new_column_name,
            ' in table ',
            in_table_name,
            '.'
        ) AS message;
    END IF;
END
$$

DELIMITER ;

SELECT 'usp_RenameColumn created successfully.' AS message;
