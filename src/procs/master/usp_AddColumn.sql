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
--   in_default_value - The default value for the column (NULL for no default, pass as raw SQL).
--   in_required      - Whether the column is required (NOT NULL). Default is FALSE.
--
-- Usage:
--   CALL usp_AddColumn('tblExample', 'new_column', 'VARCHAR(255)', '''default_value''', TRUE);
--   CALL usp_AddColumn('tblExample', 'created_at', 'TIMESTAMP', 'CURRENT_TIMESTAMP', FALSE);
--   CALL usp_AddColumn('tblExample', 'age', 'INT', '0', TRUE);
--
-- Notes:
--   - Checks if the table and column exist before attempting to add the column.
--   - If a default value is provided, it is added as DEFAULT (constraint name is not supported in MySQL).
--   - The default value is cast and quoted appropriately based on the data type.
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
    -- Declare variables for type handling and dynamic SQL
    DECLARE v_data_type VARCHAR(64);
    DECLARE v_sql VARCHAR(2000);
    DECLARE v_type_prefix VARCHAR(32);

    -- Handle any SQL exception and print a custom message
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT CONCAT(
            'Column ',
            in_column_name,
            ' addition failed due to an exception.'
        ) AS message;
    END;

    -- Always use uppercase for data type for robust comparison
    SET v_data_type = UPPER(in_data_type);
    SET v_type_prefix = SUBSTRING_INDEX(v_data_type, '(', 1);

    -- Check if table exists
    IF NOT ufn_DoesTableExist(in_table_name) THEN
        SELECT CONCAT(
            'Column ',
            in_column_name,
            ' addition failed because table ',
            in_table_name,
            ' does not exist.'
        ) AS message;
    -- Check if column already exists
    ELSEIF ufn_DoesColumnExist(in_table_name, in_column_name) THEN
        SELECT CONCAT(
            'Column ',
            in_column_name,
            ' already exists in table ',
            in_table_name,
            '.'
        ) AS message;
    ELSE
        -- Start building the ALTER TABLE statement
        SET @sql = CONCAT(
            'ALTER TABLE ', in_table_name,
            ' ADD COLUMN ', in_column_name, ' ', v_data_type
        );

        -- Add NOT NULL if required
        IF in_required THEN
            SET @sql = CONCAT(@sql, ' NOT NULL');
        END IF;

        -- Handle default value based on data type
        IF in_default_value IS NOT NULL AND in_default_value != '' THEN
            -- String types: quote if not already quoted
            IF v_type_prefix IN ('CHAR', 'VARCHAR', 'TEXT', 'TINYTEXT', 'MEDIUMTEXT', 'LONGTEXT', 'ENUM', 'SET') THEN
                IF LEFT(in_default_value, 1) = '''' AND RIGHT(in_default_value, 1) = '''' THEN
                    SET @sql = CONCAT(@sql, ' DEFAULT ', in_default_value);
                ELSE
                    SET @sql = CONCAT(@sql, ' DEFAULT ''', REPLACE(in_default_value, '''', ''''''), '''');
                END IF;
            -- Date/time types: allow functions or quote as needed
            ELSEIF v_type_prefix IN ('DATE', 'DATETIME', 'TIMESTAMP', 'TIME', 'YEAR') THEN
                IF in_default_value REGEXP '^[A-Za-z_][A-Za-z0-9_]*\\(.*\\)$' OR
                   in_default_value IN ('CURRENT_TIMESTAMP', 'NOW()') THEN
                    SET @sql = CONCAT(@sql, ' DEFAULT ', in_default_value);
                ELSEIF LEFT(in_default_value, 1) = '''' AND RIGHT(in_default_value, 1) = '''' THEN
                    SET @sql = CONCAT(@sql, ' DEFAULT ', in_default_value);
                ELSE
                    SET @sql = CONCAT(@sql, ' DEFAULT ''', REPLACE(in_default_value, '''', ''''''), '''');
                END IF;
            -- Numeric and boolean types: do not quote
            ELSEIF v_type_prefix IN ('INT', 'INTEGER', 'BIGINT', 'SMALLINT', 'TINYINT', 'MEDIUMINT', 'FLOAT', 'DOUBLE', 'DECIMAL', 'NUMERIC', 'BIT', 'BOOL', 'BOOLEAN') THEN
                SET @sql = CONCAT(@sql, ' DEFAULT ', in_default_value);
            -- Fallback: treat as string
            ELSE
                IF LEFT(in_default_value, 1) = '''' AND RIGHT(in_default_value, 1) = '''' THEN
                    SET @sql = CONCAT(@sql, ' DEFAULT ', in_default_value);
                ELSE
                    SET @sql = CONCAT(@sql, ' DEFAULT ''', REPLACE(in_default_value, '''', ''''''), '''');
                END IF;
            END IF;
        END IF;

        -- Execute the dynamic SQL to add the column
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

SELECT 'usp_AddColumn created successfully.' AS message;