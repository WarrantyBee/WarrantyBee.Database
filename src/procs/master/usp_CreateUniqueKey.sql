DELIMITER $$
DROP PROCEDURE IF EXISTS usp_CreateUniqueKey$$

-- =============================================
-- usp_CreateUniqueKey
-- Creates or replaces a UNIQUE constraint on one or more columns in a table.
--
-- Parameters:
--   in_table_name    - The name of the table to alter.
--   in_column_names  - Comma-separated column names to include in the unique key (e.g., 'col1,col2').
--
-- Usage:
--   CALL usp_CreateUniqueKey('tblExample', 'email');
--   CALL usp_CreateUniqueKey('tblExample', 'first_name,last_name');
--
-- Notes:
--   - The constraint will be named uq_{table}_{col1-col2-...}.
--   - Checks if the table and all columns exist before attempting to add the constraint.
--   - If the constraint exists, it will be dropped and recreated.
--   - Handles exceptions and prints messages for each execution flow.
--   - Always uses backticks for database objects.
-- =============================================

CREATE PROCEDURE usp_CreateUniqueKey(
    IN in_table_name VARCHAR(64),
    IN in_column_names VARCHAR(255)
)
proc:BEGIN
    -- Declare variables for constraint name, column parsing, and existence checks
    DECLARE v_constraint_name VARCHAR(255);
    DECLARE v_exists INT DEFAULT 0;
    DECLARE v_col_name VARCHAR(64);
    DECLARE v_col_list_for_constraint VARCHAR(255) DEFAULT '';
    DECLARE v_col_list_for_sql VARCHAR(255) DEFAULT '';
    DECLARE v_pos INT DEFAULT 1;
    DECLARE v_next_pos INT;
    DECLARE v_len INT;

    -- Handle any SQL exception and print a custom message
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT CONCAT(
            'Unique key creation failed for table `',
            in_table_name,
            '` due to an exception.'
        ) AS message;
    END;

    -- Check if table exists
    IF NOT ufn_DoesTableExist(in_table_name) THEN
        SELECT CONCAT(
            'Table `',
            in_table_name,
            '` does not exist.'
        ) AS message;
        LEAVE proc;
    END IF;

    -- Parse and validate all columns, build constraint and SQL column lists
    SET v_len = CHAR_LENGTH(in_column_names);
    SET v_pos = 1;
    WHILE v_pos <= v_len DO
        SET v_next_pos = LOCATE(',', in_column_names, v_pos);
        IF v_next_pos = 0 THEN
            SET v_col_name = TRIM(SUBSTRING(in_column_names, v_pos));
            SET v_pos = v_len + 1;
        ELSE
            SET v_col_name = TRIM(SUBSTRING(in_column_names, v_pos, v_next_pos - v_pos));
            SET v_pos = v_next_pos + 1;
        END IF;

        -- Check if each column exists
        IF NOT ufn_DoesColumnExist(in_table_name, v_col_name) THEN
            SELECT CONCAT(
                'Column `',
                v_col_name,
                '` does not exist in table `',
                in_table_name,
                '`.'
            ) AS message;
            LEAVE proc;
        END IF;

        -- Build constraint name and SQL column list
        SET v_col_list_for_constraint = CONCAT(
            v_col_list_for_constraint,
            IF(v_col_list_for_constraint = '', '', '-'),
            v_col_name
        );
        SET v_col_list_for_sql = CONCAT(
            v_col_list_for_sql,
            IF(v_col_list_for_sql = '', '', ','),
            '`', v_col_name, '`'
        );
    END WHILE;

    -- Build the constraint name
    SET v_constraint_name = CONCAT('uq_', in_table_name, '_', v_col_list_for_constraint);

    -- Check if unique constraint already exists
    SELECT COUNT(1) INTO v_exists
    FROM information_schema.table_constraints
    WHERE table_schema = DATABASE()
      AND table_name = in_table_name
      AND constraint_type = 'UNIQUE'
      AND constraint_name = v_constraint_name;

    IF v_exists > 0 THEN
        -- Drop the existing unique constraint (index)
        SET @sql_drop = CONCAT(
            'ALTER TABLE `', in_table_name, '` DROP INDEX `', v_constraint_name, '`'
        );
        PREPARE stmt_drop FROM @sql_drop;
        EXECUTE stmt_drop;
        DEALLOCATE PREPARE stmt_drop;

        -- Add the new unique constraint
        SET @sql_add = CONCAT(
            'ALTER TABLE `', in_table_name, '` ',
            'ADD CONSTRAINT `', v_constraint_name, '` UNIQUE (', v_col_list_for_sql, ')'
        );
        PREPARE stmt_add FROM @sql_add;
        EXECUTE stmt_add;
        DEALLOCATE PREPARE stmt_add;

        SELECT CONCAT(
            'Unique key `',
            v_constraint_name,
            '` was replaced successfully on table `',
            in_table_name,
            '`.'
        ) AS message;
    ELSE
        -- Add the new unique constraint
        SET @sql_add = CONCAT(
            'ALTER TABLE `', in_table_name, '` ',
            'ADD CONSTRAINT `', v_constraint_name, '` UNIQUE (', v_col_list_for_sql, ')'
        );
        PREPARE stmt_add FROM @sql_add;
        EXECUTE stmt_add;
        DEALLOCATE PREPARE stmt_add;

        SELECT CONCAT(
            'Unique key `',
            v_constraint_name,
            '` created successfully on table `',
            in_table_name,
            '`.'
        ) AS message;
    END IF;
END proc$$

DELIMITER ;

SELECT 'usp_CreateUniqueKey created successfully.' AS message;