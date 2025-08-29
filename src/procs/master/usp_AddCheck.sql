DELIMITER $$
DROP PROCEDURE IF EXISTS usp_AddCheck$$

-- =============================================
-- usp_AddCheck
-- Adds or updates a check constraint on a specified column in a table.
--
-- Parameters:
--   in_table_name   - The name of the table to alter.
--   in_column_name  - The name of the column to apply the check constraint on.
--   in_check_expr   - The check expression (e.g., '`age` > 0').
--
-- Usage:
--   -- Simple greater than check
--   CALL usp_AddCheck('tblExample', 'age', '`age` > 0');
--
--   -- Using IN operator
--   CALL usp_AddCheck('tblExample', 'status', "`status` IN ('active', 'pending')");
--
--   -- Using BETWEEN operator
--   CALL usp_AddCheck('tblExample', 'score', '`score` BETWEEN 1 AND 10');
--
--   -- Using LIKE operator
--   CALL usp_AddCheck('tblExample', 'email', "`email` LIKE '%@example.com'");
--
--   -- Using a function
--   CALL usp_AddCheck('tblExample', 'name', 'LENGTH(`name`) > 3');
--
-- Notes:
--   - The constraint will be named chk_{table}.{column}.
--   - Checks if the table, column, and constraint already exist before adding or updating.
--   - Handles exceptions and prints messages for each execution flow.
--   - Always uses backticks for database objects.
--   - The check expression (in_check_expr) can use any valid MySQL syntax,
--     including operators like IN, BETWEEN, LIKE, and functions.
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
            'Check constraint creation or update failed for column `',
            in_column_name,
            '` in table `',
            in_table_name,
            '` due to an exception.'
        ) AS message;
    END;

    -- Build constraint name
    SET v_constraint_name = CONCAT('chk_', in_table_name, '.', in_column_name);

    -- Check if table exists
    IF NOT ufn_DoesTableExist(in_table_name) THEN
        SELECT CONCAT(
            'Table `',
            in_table_name,
            '` does not exist.'
        ) AS message;
    -- Check if column exists
    ELSEIF NOT ufn_DoesColumnExist(in_table_name, in_column_name) THEN
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

            -- Add the new/updated constraint
            SET @sql_add = CONCAT(
                'ALTER TABLE `', in_table_name, '` ',
                'ADD CONSTRAINT `', v_constraint_name, '` CHECK (', in_check_expr, ')'
            );
            PREPARE stmt_add FROM @sql_add;
            EXECUTE stmt_add;
            DEALLOCATE PREPARE stmt_add;

            SELECT CONCAT(
                'Check constraint `',
                v_constraint_name,
                '` updated successfully on table `',
                in_table_name,
                '`.'
            ) AS message;
        ELSE
            -- Add the new constraint
            SET @sql_add = CONCAT(
                'ALTER TABLE `', in_table_name, '` ',
                'ADD CONSTRAINT `', v_constraint_name, '` CHECK (', in_check_expr, ')'
            );
            PREPARE stmt_add FROM @sql_add;
            EXECUTE stmt_add;
            DEALLOCATE PREPARE stmt_add;

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
$$

DELIMITER ;