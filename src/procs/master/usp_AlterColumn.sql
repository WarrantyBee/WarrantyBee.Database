DELIMITER $$
DROP PROCEDURE IF EXISTS usp_AlterColumn$$

-- =============================================
-- usp_AlterColumn
-- Alters the data type, nullability, and default value of a column in a specified table.
--
-- Parameters:
--   in_table_name    - The name of the table to alter.
--   in_column_name   - The name of the column to modify.
--   in_data_type     - The new data type (e.g., 'VARCHAR(500)'). NULL to keep existing.
--   in_required      - TRUE for NOT NULL, FALSE for NULL. NULL to keep existing.
--   in_default_value - New default value. NULL to keep existing, 'NULL' string to set DEFAULT NULL.
--
-- Usage:
--   -- Change data type only
--   CALL usp_AlterColumn('tblExample', 'col1', 'VARCHAR(500)', NULL, NULL);
--   -- Make a column required
--   CALL usp_AlterColumn('tblExample', 'col1', NULL, TRUE, NULL);
--   -- Change the default value
--   CALL usp_AlterColumn('tblExample', 'col1', NULL, NULL, '''new_default''');
--   -- Set default to NULL
--   CALL usp_AlterColumn('tblExample', 'col1', NULL, FALSE, 'NULL');
--   -- Do multiple changes at once
--   CALL usp_AlterColumn('tblExample', 'col1', 'BIGINT', TRUE, '''0''');
--
-- Notes:
--   - If all optional parameters (in_data_type, in_required, in_default_value) are NULL, no action is taken.
--   - It preserves existing settings for any parameter that is passed as NULL.
-- =============================================

CREATE PROCEDURE usp_AlterColumn(
    IN in_table_name VARCHAR(64),
    IN in_column_name VARCHAR(64),
    IN in_data_type VARCHAR(64),
    IN in_required BOOLEAN,
    IN in_default_value VARCHAR(255)
)
BEGIN
    -- Declare variables for existing column properties
    DECLARE v_current_data_type VARCHAR(64);
    DECLARE v_current_is_nullable VARCHAR(3);
    DECLARE v_current_default_value TEXT;
    DECLARE v_alter_sql TEXT;
    DECLARE v_default_clause VARCHAR(512) DEFAULT '';

    -- Handle any SQL exception
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT CONCAT(
            'Column ', in_column_name, ' modification failed due to an exception.'
        ) AS message;
        ROLLBACK;
    END;

    -- If no changes are requested, do nothing
    IF in_data_type IS NULL AND in_required IS NULL AND in_default_value IS NULL THEN
        SELECT 'No changes requested for column.' AS message;
    -- Check for table and column existence
    ELSEIF NOT ufn_DoesTableExist(in_table_name) THEN
        SELECT CONCAT('Table ', in_table_name, ' does not exist.') AS message;
    ELSEIF NOT ufn_DoesColumnExist(in_table_name, in_column_name) THEN
        SELECT CONCAT('Column ', in_column_name, ' does not exist in table ', in_table_name, '.') AS message;
    ELSE
        -- Get current column properties from information_schema
        SELECT
            COLUMN_TYPE, IS_NULLABLE, COLUMN_DEFAULT
        INTO
            v_current_data_type, v_current_is_nullable, v_current_default_value
        FROM information_schema.columns
        WHERE table_schema = DATABASE()
          AND table_name = in_table_name
          AND column_name = in_column_name;

        -- Determine the final data type
        SET v_current_data_type = COALESCE(in_data_type, v_current_data_type);

        -- Build the ALTER TABLE statement
        SET v_alter_sql = CONCAT('ALTER TABLE ', in_table_name, ' MODIFY COLUMN ', in_column_name, ' ', v_current_data_type);

        -- Determine the final nullability
        IF in_required IS NOT NULL THEN
            SET v_alter_sql = CONCAT(v_alter_sql, IF(in_required, ' NOT NULL', ' NULL'));
        ELSE
            SET v_alter_sql = CONCAT(v_alter_sql, IF(v_current_is_nullable = 'NO', ' NOT NULL', ' NULL'));
        END IF;

        -- Determine the final default value clause (tristate logic)
        IF in_default_value IS NOT NULL THEN
            -- State 2: Set to NULL
            IF in_default_value = 'NULL' THEN
                SET v_default_clause = ' DEFAULT NULL';
            -- State 3: Change to a new value
            ELSE
                SET v_default_clause = CONCAT(' DEFAULT ', in_default_value);
            END IF;
        -- State 1: Persist existing default
        ELSE
            IF v_current_default_value IS NOT NULL THEN
                -- Need to check if the default is a function or needs quoting
                IF v_current_default_value REGEXP '^[A-Za-z_][A-Za-z0-9_]*\\(.*\\)$' OR
                   v_current_default_value IN ('CURRENT_TIMESTAMP') OR
                   NOT (
                       v_current_data_type LIKE '%char%' OR
                       v_current_data_type LIKE '%text%' OR
                       v_current_data_type LIKE '%date%' OR
                       v_current_data_type LIKE '%time%'
                   )
                THEN
                     SET v_default_clause = CONCAT(' DEFAULT ', v_current_default_value);
                ELSE
                     SET v_default_clause = CONCAT(' DEFAULT ''', REPLACE(v_current_default_value, '''', ''''''), '''');
                END IF;
            END IF;
        END IF;

        SET v_alter_sql = CONCAT(v_alter_sql, v_default_clause);

        -- Execute the dynamic SQL
        SET @sql = v_alter_sql;
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SELECT CONCAT('Column ', in_column_name, ' in table ', in_table_name, ' altered successfully.') AS message;
    END IF;
END
$$

DELIMITER ;

SELECT 'usp_AlterColumn created successfully.' AS message;
