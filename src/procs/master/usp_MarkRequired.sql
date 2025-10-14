DELIMITER $$
DROP PROCEDURE IF EXISTS usp_MarkRequired$$

-- =============================================
-- usp_MarkRequired
-- Alters a column in a table to set or unset the NOT NULL (required) constraint.
--
-- Parameters:
--   in_table_name   - The name of the table to alter.
--   in_column_name  - The name of the column to modify.
--   in_required     - TRUE to make the column required (NOT NULL), FALSE to allow NULLs.
--
-- Usage:
--   CALL usp_MarkRequired('tblExample', 'colName', TRUE);
--
-- Notes:
--   - Checks if the table and column exist before attempting to alter.
--   - Handles exceptions and prints messages for each execution flow.
--   - The column's data type is preserved.
-- =============================================

CREATE PROCEDURE usp_MarkRequired(
    IN in_table_name VARCHAR(64),     -- Table name input
    IN in_column_name VARCHAR(64),    -- Column name input
    IN in_required BOOLEAN            -- TRUE = make NOT NULL, FALSE = allow NULL
)
BEGIN
    DECLARE v_data_type VARCHAR(255); -- Stores column's existing data type

    -- Exception handler: catches any SQL errors during execution
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Return failure message if something goes wrong
        SELECT CONCAT(
            'Failed to update required flag for column ',
            in_column_name,
            ' in table ',
            in_table_name,
            '.'
        ) AS message;
    END;

    -- Check if table exists
    IF NOT ufn_DoesTableExist(in_table_name) THEN
        -- Inform user if table does not exist
        SELECT CONCAT(
            'Table ',
            in_table_name,
            ' does not exist.'
        ) AS message;

    -- Check if column exists
    ELSEIF NOT ufn_DoesColumnExist(in_table_name, in_column_name) THEN
        -- Inform user if column missing
        SELECT CONCAT(
            'Column ',
            in_column_name,
            ' does not exist in table ',
            in_table_name,
            '.'
        ) AS message;

    ELSE
        -- Retrieve column data type (so we can preserve it when altering)
        SELECT COLUMN_TYPE
        INTO v_data_type
        FROM information_schema.columns
        WHERE table_schema = DATABASE()
          AND table_name = in_table_name
          AND column_name = in_column_name;

        -- Build dynamic SQL to modify column with NOT NULL or NULL
        SET @sql = CONCAT(
            'ALTER TABLE ', in_table_name,
            ' MODIFY COLUMN ', in_column_name, ' ', v_data_type,
            IF(in_required, ' NOT NULL', ' NULL')
        );

        -- Execute dynamic SQL
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        -- Success message
        SELECT CONCAT(
            'Column ',
            in_column_name,
            IF(in_required, ' is now required (NOT NULL)', ' is now nullable (NULL)'),
            ' in table ',
            in_table_name,
            '.'
        ) AS message;
    END IF;
END
$$

DELIMITER ;

SELECT 'usp_MarkRequired created successfully.' AS message;