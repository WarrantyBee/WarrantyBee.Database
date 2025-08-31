DELIMITER $
DROP PROCEDURE IF EXISTS usp_AddCheck$

-- =============================================
-- usp_AddCheck
-- Adds or updates a check constraint on a specified column or a custom check on multiple columns in a table.
--
-- Parameters:
--   in_table_name      - The name of the table to alter.
--   in_column_name     - (Optional) The name of the column to apply the check constraint on. If NULL, it's a table-level constraint.
--   in_check_expr      - The check expression (e.g., '`age` > 0').
--
-- Usage:
--   -- Simple greater than check on a column
--   CALL usp_AddCheck('tblExample', 'age', '`age` > 0');
--
--   -- Custom check on multiple columns (constraint name will be auto-generated)
--   CALL usp_AddCheck('tblExample', NULL, '`start_date` < `end_date`');
--
-- Notes:
--   - If column name is provided, the constraint will be named chk_{table}.{column}.
--   - If column name is not provided, a random name will be generated.
--   - Checks if the table, column (if applicable), and constraint already exist before adding or updating.
--   - Handles exceptions and prints messages for each execution flow.
-- =============================================

CREATE PROCEDURE usp_AddCheck(
    IN in_table_name VARCHAR(64),
    IN in_column_name VARCHAR(64),
    IN in_check_expr VARCHAR(512)
)
BEGIN
    DECLARE v_constraint_name VARCHAR(130);
    DECLARE v_exists INT DEFAULT 0;

    -- Handle any SQL exception and print a custom message
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT CONCAT(
            'Check constraint creation or update failed for table `',
            in_table_name,
            '` due to an exception.'
        ) AS message;
    END;

    -- Build constraint name
    IF in_column_name IS NOT NULL THEN
        SET v_constraint_name = CONCAT('chk_', in_table_name, '.', in_column_name);
    ELSE
        SET v_constraint_name = CONCAT('chk_', in_table_name, '_', REPLACE(UUID(), '-', ''));
    END IF;

    -- Check if table exists
    IF NOT ufn_DoesTableExist(in_table_name) THEN
        SELECT CONCAT(
            'Table `',
            in_table_name,
            '` does not exist.'
        ) AS message;
    -- Check if column exists, only if a column name is provided
    ELSEIF in_column_name IS NOT NULL AND NOT ufn_DoesColumnExist(in_table_name, in_column_name) THEN
        SELECT CONCAT(
            'Column `',
            in_column_name,
            '` does not exist in table `',
            in_table_name,
            '`.'
        ) AS message;
    ELSE
        -- Check if the constraint already exists
        SELECT COUNT(1) INTO v_exists
        FROM information_schema.table_constraints
        WHERE table_schema = DATABASE()
          AND table_name = in_table_name
          AND constraint_type = 'CHECK'
          AND constraint_name = v_constraint_name;

        IF v_exists > 0 THEN
            -- Drop the existing constraint before adding the new one
            SET @sql_drop = CONCAT(
                'ALTER TABLE `', in_table_name, '` DROP CONSTRAINT `', v_constraint_name, '`'
            );
            PREPARE stmt_drop FROM @sql_drop;
            EXECUTE stmt_drop;
            DEALLOCATE PREPARE stmt_drop;
        END IF;

        -- Add the new/updated constraint
        SET @sql_add = CONCAT(
            'ALTER TABLE `', in_table_name, '` ',
            'ADD CONSTRAINT `', v_constraint_name, '` CHECK (', in_check_expr, ')'
        );
        PREPARE stmt_add FROM @sql_add;
        EXECUTE stmt_add;
        DEALLOCATE PREPARE stmt_add;

        IF v_exists > 0 THEN
            SELECT CONCAT(
                'Check constraint `',
                v_constraint_name,
                '` updated successfully on table `',
                in_table_name,
                '`.'
            ) AS message;
        ELSE
            SELECT CONCAT(
                'Check constraint `',
                v_constraint_name,
                '` added successfully to table `',
                in_table_name,
                '`.'
            ) AS message;
        END IF;
    END IF;
END
$

DELIMITER ;