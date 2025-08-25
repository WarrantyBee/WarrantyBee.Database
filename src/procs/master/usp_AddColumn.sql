DELIMITER $$
DROP PROCEDURE IF EXISTS usp_AddColumn$$

-- =============================================
-- usp_AddColumn
-- Adds a column to a specified table if it does not already exist.
--
-- Parameters:
--   in_table_name    - The name of the table to alter.
--   in_column_name   - The name of the column to add.
--   in_data_type     - The data type of the new column (e.g., 'VARCHAR(255)', 'INT').
--   in_default_value - The default value for the column (NULL for no default).
--   in_required      - Whether the column is required (NOT NULL). Default is FALSE.
--
-- Usage:
--   CALL usp_AddColumn('tblExample', 'new_column', 'VARCHAR(255)', 'default_value', TRUE);
--
-- Notes:
--   - Checks if the table and column exist before attempting to add the column.
--   - If a default value is provided, a default constraint is created with the name df_{table}.{column}.
--   - Prints messages for every execution flow and handles exceptions.
-- =============================================

CREATE PROCEDURE usp_AddColumn(
    IN in_table_name VARCHAR(64),
    IN in_column_name VARCHAR(64),
    IN in_data_type VARCHAR(64),
    IN in_default_value VARCHAR(255),
    IN in_required BOOLEAN
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT CONCAT(
            'Column ',
            in_column_name,
            ' addition failed due to an exception.'
        ) AS message;
    END;

    IF NOT ufn_DoesTableExist(in_table_name) THEN
        SELECT CONCAT(
            'Column ',
            in_column_name,
            ' addition failed because table ',
            in_table_name,
            ' does not exist.'
        ) AS message;
    ELSEIF ufn_DoesColumnExist(in_table_name, in_column_name) THEN
        SELECT CONCAT(
            'Column ',
            in_column_name,
            ' already exists in table ',
            in_table_name,
            '.'
        ) AS message;
    ELSE
        SET @sql = CONCAT(
            'ALTER TABLE ', in_table_name,
            ' ADD COLUMN ', in_column_name, ' ', in_data_type
        );

        IF in_required THEN
            SET @sql = CONCAT(@sql, ' NOT NULL');
        END IF;

        IF in_default_value IS NOT NULL AND in_default_value != '' THEN
            SET @sql = CONCAT(
                @sql,
                ' CONSTRAINT ',
                'df_', in_table_name, '.', in_column_name,
                ' DEFAULT ''', REPLACE(in_default_value, '''', ''''''), ''''
            );
        END IF;

        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SELECT CONCAT(
            'Column ',
            in_column_name,
            ' added successfully to table ',
            in_table_name,
            '.'
        ) AS message;
    END IF;
END
$$

DELIMITER ;
