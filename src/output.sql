-- Script: ufn_DoesColumnExist.sql

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


-- Script: ufn_DoesTableExist.sql

DELIMITER $$
DROP FUNCTION IF EXISTS ufn_DoesTableExist$$

-- =============================================
-- ufn_DoesTableExist
-- Checks if a specific table exists within the current database.
--
-- Parameters:
--   in_table_name - The name of the table to check for existence.
--
-- Returns:
--   TRUE if the table exists in the current database, otherwise FALSE.
--
-- Notes:
--   - Returns FALSE if an error occurs during execution.
--   - The function is deterministic and only checks in the current database.
-- =============================================

CREATE FUNCTION ufn_DoesTableExist(in_table_name VARCHAR(64))
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    -- Variable to store existence result
    DECLARE v_exists BOOLEAN DEFAULT FALSE;

    -- If any SQL exception occurs, set result to FALSE
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        SET v_exists = FALSE;

    -- Check for the table in information_schema.tables
    SELECT TRUE
    INTO v_exists
    FROM information_schema.tables
    WHERE table_schema = DATABASE()
      AND table_name = in_table_name
    LIMIT 1;

    -- Return TRUE if found, otherwise FALSE
    RETURN v_exists;
END$$

DELIMITER ;


-- Script: ufn_DoColumnsExist.sql

DELIMITER $$
DROP FUNCTION IF EXISTS ufn_DoColumnsExist$$

-- =============================================
-- ufn_DoColumnsExist
-- Checks if a comma-separated list of columns exists in a given table.
--
-- Parameters:
--   in_table_name   - The name of the table to check.
--   in_column_names - A comma-separated string of column names.
--
-- Returns:
--   TRUE if all columns exist, otherwise FALSE.
-- =============================================

CREATE FUNCTION ufn_DoColumnsExist(
    in_table_name VARCHAR(64),
    in_column_names VARCHAR(255)
)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE v_col_name VARCHAR(64);
    DECLARE v_remaining_cols VARCHAR(255) DEFAULT in_column_names;
    DECLARE v_comma_pos INT;

    WHILE v_remaining_cols IS NOT NULL AND v_remaining_cols != '' DO
        SET v_comma_pos = LOCATE(',', v_remaining_cols);
        IF v_comma_pos > 0 THEN
            SET v_col_name = TRIM(SUBSTRING(v_remaining_cols, 1, v_comma_pos - 1));
            SET v_remaining_cols = TRIM(SUBSTRING(v_remaining_cols, v_comma_pos + 1));
        ELSE
            SET v_col_name = TRIM(v_remaining_cols);
            SET v_remaining_cols = '';
        END IF;

        IF NOT ufn_DoesColumnExist(in_table_name, v_col_name) THEN
            RETURN FALSE;
        END IF;
    END WHILE;

    RETURN TRUE;
END$$

DELIMITER ;


-- Script: usp_DropColumn.sql

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


-- Script: usp_CreatePrimaryKey.sql

DELIMITER $$
DROP PROCEDURE IF EXISTS usp_CreatePrimaryKey$$

-- =============================================
-- usp_CreatePrimaryKey
-- Creates a PRIMARY KEY constraint on a specified table and column if one does not already exist.
--
-- Parameters:
--   in_table_name       - The name of the table to alter.
--   in_column_name      - The name of the column to set as the PRIMARY KEY.
--   in_constraint_name  - The name to assign to the PRIMARY KEY constraint.
--
-- Usage:
--   CALL usp_CreatePrimaryKey('tblUsers', 'id', 'pk_tblUsers.id');
--
-- Notes:
--   - The procedure checks if a PRIMARY KEY already exists on the table before attempting to add one.
--   - If no PRIMARY KEY exists, it uses dynamic SQL to add the specified PRIMARY KEY constraint.
--   - The constraint will be created with the provided name on the specified column.
--   - Checks for table and column existence before attempting to add the constraint.
--   - Prints messages for every execution flow and handles exceptions.
-- =============================================

CREATE PROCEDURE usp_CreatePrimaryKey(
    IN in_table_name VARCHAR(64),
    IN in_column_name VARCHAR(64),
    IN in_constraint_name VARCHAR(64)
)
BEGIN
    -- Handle any SQL exception and print a custom message
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT CONCAT(
            'Primary key ',
            in_constraint_name,
            ' creation failed due to an exception.'
        ) AS message;
    END;

    -- Check if table exists
    IF NOT ufn_DoesTableExist(in_table_name) THEN
        SELECT CONCAT(
            'Primary key ',
            in_constraint_name,
            ' creation failed due to table ',
            in_table_name,
            ' does not exist.'
        ) AS message;
    -- Check if column exists
    ELSEIF NOT ufn_DoesColumnExist(in_table_name, in_column_name) THEN
        SELECT CONCAT(
            'Primary key ',
            in_constraint_name,
            ' creation failed due to column ',
            in_column_name,
            ' does not exist on the table ',
            in_table_name, ' .'
        ) AS message;
    -- Check if primary key already exists
    ELSEIF EXISTS (
        SELECT 1
        FROM information_schema.table_constraints
        WHERE table_name = in_table_name
          AND table_schema = DATABASE()
          AND constraint_type = 'PRIMARY KEY'
    ) THEN
        SELECT CONCAT(
            'Primary key ',
            in_constraint_name,
            ' already exists.'
        )  AS message;
    ELSE
        -- Try to create the primary key constraint
        BEGIN
            DECLARE EXIT HANDLER FOR SQLEXCEPTION
            BEGIN
                SELECT CONCAT(
                    'Primary key ',
                    in_constraint_name,
                    ' creation failed due to an exception.'
                ) AS message;
            END;

            -- Build and execute the ALTER TABLE statement
            SET @sql = CONCAT('ALTER TABLE ', in_table_name,
                              ' ADD CONSTRAINT `', in_constraint_name,
                              '` PRIMARY KEY (', in_column_name, ')');
            PREPARE stmt FROM @sql;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;

            SELECT CONCAT(
                'Primary key ',
                in_constraint_name,
                ' created successfully.'
            ) AS message;
        END;
    END IF;
END
$$

DELIMITER ;



-- Script: usp_CreateForeignKey.sql

DELIMITER $$
DROP PROCEDURE IF EXISTS usp_CreateForeignKey$$

-- =============================================
-- usp_CreateForeignKey
-- Creates a FOREIGN KEY constraint on a specified table and column if one does not already exist.
--
-- Parameters:
--   in_table_name        - The name of the table to alter.
--   in_column_name       - The column in the table to be set as the foreign key.
--   in_ref_table_name    - The referenced table.
--   in_ref_column_name   - The referenced column in the referenced table.
--
-- Usage:
--   CALL usp_CreateForeignKey(
--       'tblBooks',
--       'category_id',
--       'tblCategories',
--       'id'
--   );
--
-- Notes:
--   - The constraint will be named fk_{ref_table}_{table}.{column}.
--   - Checks if the table, columns, and referenced table/column exist before attempting to add the constraint.
--   - Handles exceptions and prints messages for each execution flow.
--   - Always uses backticks for database objects.
-- =============================================

CREATE PROCEDURE usp_CreateForeignKey(
    IN in_table_name VARCHAR(64),
    IN in_column_name VARCHAR(64),
    IN in_ref_table_name VARCHAR(64),
    IN in_ref_column_name VARCHAR(64)
)
BEGIN
    DECLARE v_constraint_name VARCHAR(200);

    -- Handle any SQL exception and print a custom message
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT CONCAT(
            'Foreign key `',
            v_constraint_name,
            '` creation failed due to an exception.'
        ) AS message;
    END;

    -- Build the constraint name using referenced and child table/column
    SET v_constraint_name = CONCAT('fk_', in_ref_table_name, '_', in_table_name, '.', in_column_name);
    
    -- Check if table and columns exist
    IF NOT ufn_DoesTableExist(in_table_name) THEN
        SELECT CONCAT(
            'Foreign key `',
            v_constraint_name,
            '` creation failed due to table `',
            in_table_name,
            '` does not exist.'
        ) AS message;
    ELSEIF NOT ufn_DoesColumnExist(in_table_name, in_column_name) THEN
        SELECT CONCAT(
            'Foreign key `',
            v_constraint_name,
            '` creation failed due to column `',
            in_column_name,
            '` does not exist on the table `',
            in_table_name, '`.'
        ) AS message;
    ELSEIF NOT ufn_DoesTableExist(in_ref_table_name) THEN
        SELECT CONCAT(
            'Foreign key `',
            v_constraint_name,
            '` creation failed due to referenced table `',
            in_ref_table_name,
            '` does not exist.'
        ) AS message;
    ELSEIF NOT ufn_DoesColumnExist(in_ref_table_name, in_ref_column_name) THEN
        SELECT CONCAT(
            'Foreign key `',
            v_constraint_name,
            '` creation failed due to referenced column `',
            in_ref_column_name,
            '` does not exist on the table `',
            in_ref_table_name, '`.'
        ) AS message;
    -- Check if the constraint already exists
    ELSEIF EXISTS (
        SELECT 1
        FROM information_schema.table_constraints
        WHERE table_schema = DATABASE()
          AND table_name = in_table_name
          AND constraint_type = 'FOREIGN KEY'
          AND constraint_name = v_constraint_name
    ) THEN
        SELECT CONCAT(
            'Foreign key `',
            v_constraint_name,
            '` already exists.'
        ) AS message;
    ELSE
        -- Try to create the foreign key constraint
        BEGIN
            DECLARE EXIT HANDLER FOR SQLEXCEPTION
            BEGIN
                SELECT CONCAT(
                    'Foreign key `',
                    v_constraint_name,
                    '` creation failed.'
                ) AS message;
            END;

            -- Build and execute the ALTER TABLE statement
            SET @sql = CONCAT(
                'ALTER TABLE `', in_table_name,
                '` ADD CONSTRAINT `', v_constraint_name,
                '` FOREIGN KEY (`', in_column_name, '`)',
                ' REFERENCES `', in_ref_table_name, '`(`', in_ref_column_name, '`)'
            );
            PREPARE stmt FROM @sql;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;

            SELECT CONCAT(
                'Foreign key `',
                v_constraint_name,
                '` created successfully.'
            ) AS message;
        END;
    END IF;
END
$$

DELIMITER ;


-- Script: usp_CreateUniqueKey.sql

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


-- Script: usp_CreateIndex.sql

DELIMITER $$
DROP PROCEDURE IF EXISTS usp_CreateIndex$$

-- =============================================
-- usp_CreateIndex
-- Creates an INDEX on a specified table and column(s) if one does not already exist.
--
-- Parameters:
--   in_table_name     - The name of the table to alter.
--   in_index_columns  - The column(s) in the table to be indexed (comma-separated if multiple).
--
-- Usage:
--   CALL usp_CreateIndex(
--       'tblBooks',
--       'category_id, author_id'
--   );
--
-- Notes:
--   - Index name is auto-generated as: idx_{table}_{col1-col2-coln}.
--   - Checks if the table and columns exist before attempting to add the index.
--   - Checks if the index already exists before creation.
--   - Handles exceptions and prints messages for each execution flow.
--   - Always uses backticks for database objects.
-- =============================================

CREATE PROCEDURE usp_CreateIndex(
    IN in_table_name VARCHAR(64),
    IN in_index_columns VARCHAR(255)   -- supports multiple columns, comma-separated
)
BEGIN
    DECLARE v_index_name VARCHAR(255);
    DECLARE v_index_columns_clean VARCHAR(255);

    -- Handle any SQL exception and print a custom message
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT CONCAT(
            'Index `',
            v_index_name,
            '` creation failed due to an exception.'
        ) AS message;
    END;
    
    -- Clean column list: replace commas+spaces with hyphens for index name
    SET v_index_columns_clean = REPLACE(REPLACE(in_index_columns, ', ', '-'), ',', '-');

    -- Build the auto-generated index name
    SET v_index_name = CONCAT('idx_', in_table_name, '_', v_index_columns_clean);

    -- Check if table exists
    IF NOT ufn_DoesTableExist(in_table_name) THEN
        SELECT CONCAT(
            'Index `',
            v_index_name,
            '` creation failed due to table `',
            in_table_name,
            '` does not exist.'
        ) AS message;
    -- Check if all columns exist
    ELSEIF NOT ufn_DoColumnsExist(in_table_name, in_index_columns) THEN
        SELECT CONCAT(
            'Index `',
            v_index_name,
            '` creation failed due to one or more columns `',
            in_index_columns,
            '` not existing on the table `',
            in_table_name, '`.'
        ) AS message;
    -- Check if index already exists
    ELSEIF EXISTS (
        SELECT 1
        FROM information_schema.statistics
        WHERE table_schema = DATABASE()
          AND table_name = in_table_name
          AND index_name = v_index_name
    ) THEN
        SELECT CONCAT(
            'Index `',
            v_index_name,
            '` already exists on table `',
            in_table_name, '`.'
        ) AS message;
    ELSE
        -- Try to create the index
        BEGIN
            DECLARE EXIT HANDLER FOR SQLEXCEPTION
            BEGIN
                SELECT CONCAT(
                    'Index `',
                    v_index_name,
                    '` creation failed.'
                ) AS message;
            END;

            -- Build and execute the CREATE INDEX statement
            SET @sql = CONCAT(
                'CREATE INDEX `', v_index_name,
                '` ON `', in_table_name, '` (', in_index_columns, ')'
            );
            PREPARE stmt FROM @sql;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;

            SELECT CONCAT(
                'Index `',
                v_index_name,
                '` created successfully on table `',
                in_table_name, '`.'
            ) AS message;
        END;
    END IF;
END
$$

DELIMITER ;


-- Script: usp_MarkRequired.sql

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


-- Script: usp_AddColumn.sql

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
                   in_default_value IN ('CURRENT_TIMESTAMP', 'UTC_TIMESTAMP', 'NOW()') THEN
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


-- Script: usp_AddCheck.sql

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


-- Script: usp_AutoIncrement.sql

DELIMITER $$
DROP PROCEDURE IF EXISTS usp_AutoIncrement$$

-- =============================================
-- usp_AutoIncrement
-- Alters a column in a table to make it AUTO_INCREMENT if it is not already.
--
-- Parameters:
--   in_table_name   - The name of the table to alter.
--   in_column_name  - The name of the column to modify.
--
-- Usage:
--   CALL usp_AutoIncrement('tblExample', 'id');
--
-- Notes:
--   - Checks if the table and column exist before attempting to alter.
--   - Only works for integer columns that are not already AUTO_INCREMENT.
--   - Handles exceptions and prints messages for each execution flow.
-- =============================================

CREATE PROCEDURE usp_AutoIncrement(
    IN in_table_name VARCHAR(64),
    IN in_column_name VARCHAR(64)
)
BEGIN
    -- Variables to hold column type and extra info (like AUTO_INCREMENT)
    DECLARE v_data_type VARCHAR(64);
    DECLARE v_extra VARCHAR(64);

    -- Handle any SQL exception and print a custom message
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT CONCAT(
            'Failed to set AUTO_INCREMENT for column ',
            in_column_name,
            ' in table ',
            in_table_name,
            '.'
        ) AS message;
    END;

    -- Check if table exists
    IF NOT ufn_DoesTableExist(in_table_name) THEN
        SELECT CONCAT(
            'Table ',
            in_table_name,
            ' does not exist.'
        ) AS message;
    -- Check if column exists
    ELSEIF NOT ufn_DoesColumnExist(in_table_name, in_column_name) THEN
        SELECT CONCAT(
            'Column ',
            in_column_name,
            ' does not exist in table ',
            in_table_name,
            '.'
        ) AS message;
    ELSE
        -- Get column type and extra info
        SELECT COLUMN_TYPE, EXTRA
        INTO v_data_type, v_extra
        FROM information_schema.columns
        WHERE table_schema = DATABASE()
          AND table_name = in_table_name
          AND column_name = in_column_name;

        -- If already AUTO_INCREMENT, inform the user
        IF v_extra LIKE '%auto_increment%' THEN
            SELECT CONCAT(
                'Column ',
                in_column_name,
                ' is already AUTO_INCREMENT in table ',
                in_table_name,
                '.'
            ) AS message;
        -- Only integer types can be set to AUTO_INCREMENT
        ELSEIF v_data_type NOT REGEXP '^(int|bigint|smallint|mediumint|tinyint)' THEN
            SELECT CONCAT(
                'Column ',
                in_column_name,
                ' is not an integer type and cannot be set to AUTO_INCREMENT.'
            ) AS message;
        ELSE
            -- Alter the column to set AUTO_INCREMENT
            SET @sql = CONCAT(
                'ALTER TABLE ', in_table_name,
                ' MODIFY COLUMN ', in_column_name, ' ', v_data_type, ' NOT NULL AUTO_INCREMENT'
            );
            PREPARE stmt FROM @sql;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;

            SELECT CONCAT(
                'Column ',
                in_column_name,
                ' is now AUTO_INCREMENT in table ',
                in_table_name,
                '.'
            ) AS message;
        END IF;
    END IF;
END
$$

DELIMITER ;


-- Script: usp_DropConstraint.sql

DELIMITER $$
DROP PROCEDURE IF EXISTS usp_DropConstraint$$

-- =============================================
-- usp_DropConstraint
-- Drops a constraint (PRIMARY KEY, UNIQUE, FOREIGN KEY, or CHECK) from a table if it exists.
--
-- Parameters:
--   in_table_name      - The name of the table to alter.
--   in_constraint_name - The name of the constraint to drop.
--
-- Usage:
--   CALL usp_DropConstraint('tblExample', 'UQ_tblExample_email');
--
-- Notes:
--   - Checks if the table and constraint exist before attempting to drop.
--   - Handles exceptions and prints messages for each execution flow.
--   - Always uses backticks for database objects.
-- =============================================

CREATE PROCEDURE usp_DropConstraint(
    IN in_table_name VARCHAR(64),        -- Table name input
    IN in_constraint_name VARCHAR(128)   -- Constraint name input
)
BEGIN
    DECLARE v_constraint_type VARCHAR(32);  -- Stores type of constraint
    DECLARE v_exists INT DEFAULT 0;         -- Flag (unused, but reserved)

    -- Exception handler: catches any SQL errors during execution
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Return failure message if exception occurs
        SELECT CONCAT(
            'Failed to drop constraint `',
            in_constraint_name,
            '` from table `',
            in_table_name,
            '` due to an exception.'
        ) AS message;
    END;

    -- Check if table exists
    IF NOT ufn_DoesTableExist(in_table_name) THEN
        -- Inform user if table does not exist
        SELECT CONCAT(
            'Table `',
            in_table_name,
            '` does not exist.'
        ) AS message;
    ELSE
        -- Check if constraint exists in INFORMATION_SCHEMA and get its type
        SELECT constraint_type
        INTO v_constraint_type
        FROM information_schema.table_constraints
        WHERE table_schema = DATABASE()          -- Current database
          AND table_name = in_table_name
          AND constraint_name = in_constraint_name
        LIMIT 1;

        -- If no constraint found, return message
        IF v_constraint_type IS NULL THEN
            SELECT CONCAT(
                'Constraint `',
                in_constraint_name,
                '` does not exist on table `',
                in_table_name,
                '`.'
            ) AS message;
        ELSE
            -- Build SQL based on constraint type
            IF v_constraint_type = 'PRIMARY KEY' THEN
                -- Drop primary key
                SET @sql = CONCAT('ALTER TABLE `', in_table_name, '` DROP PRIMARY KEY');

            ELSEIF v_constraint_type = 'UNIQUE' OR v_constraint_type = 'FOREIGN KEY' THEN
                -- Drop index (applies to UNIQUE & FK indexes)
                SET @sql = CONCAT('ALTER TABLE `', in_table_name, '` DROP INDEX `', in_constraint_name, '`');

                -- For FOREIGN KEY: must also explicitly drop FK constraint
                IF v_constraint_type = 'FOREIGN KEY' THEN
                    SET @sql_fk = CONCAT('ALTER TABLE `', in_table_name, '` DROP FOREIGN KEY `', in_constraint_name, '`');
                    PREPARE stmt_fk FROM @sql_fk;
                    EXECUTE stmt_fk;
                    DEALLOCATE PREPARE stmt_fk;
                END IF;

            ELSEIF v_constraint_type = 'CHECK' THEN
                -- Drop check constraint
                SET @sql = CONCAT('ALTER TABLE `', in_table_name, '` DROP CHECK `', in_constraint_name, '`');

            ELSE
                -- Fallback: try dropping as index
                SET @sql = CONCAT('ALTER TABLE `', in_table_name, '` DROP INDEX `', in_constraint_name, '`');
            END IF;

            -- Execute drop (skip if FK handled separately above)
            IF v_constraint_type != 'FOREIGN KEY' THEN
                PREPARE stmt FROM @sql;
                EXECUTE stmt;
                DEALLOCATE PREPARE stmt;
            END IF;

            -- Success message
            SELECT CONCAT(
                'Constraint `',
                in_constraint_name,
                '` of type ',
                v_constraint_type,
                ' dropped successfully from table `',
                in_table_name,
                '`.'
            ) AS message;
        END IF;
    END IF;
END
$$

DELIMITER ;


-- Script: usp_CreateTable.sql

DELIMITER $$
DROP PROCEDURE IF EXISTS usp_CreateTable$$

-- =============================================
-- usp_CreateTable
-- Creates a table with columns 'id', 'created_by', 'updated_by', 'created_at', 'updated_at', and 'void'
-- if it does not already exist, and adds a primary key constraint using usp_CreatePrimaryKey.
--
-- Parameters:
--   in_table_name - The name of the table to create.
--
-- Usage:
--   CALL usp_CreateTable('tblExample');
--
-- Notes:
--   - The procedure checks if the table already exists using ufn_DoesTableExist before creating it.
--   - The created table will have columns: id INT AUTO_INCREMENT, created_by INT NOT NULL, updated_by INT,
--     created_at TIMESTAMP NOT NULL DEFAULT UTC_TIMESTAMP, updated_at TIMESTAMP, void BOOLEAN DEFAULT FALSE.
--   - After creation, it calls usp_CreatePrimaryKey to add the primary key constraint named pk_{table}.id.
--   - Other columns are added using usp_AddColumn.
--   - Prints messages for every execution flow and handles exceptions.
-- =============================================

CREATE PROCEDURE usp_CreateTable(
    IN in_table_name VARCHAR(64)
)
BEGIN
    -- Handle any SQL exception and print a custom message
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT CONCAT(
            'Table ',
            in_table_name,
            ' creation failed due to an exception.'
        ) AS message;
    END;

    -- Check if table already exists
    IF ufn_DoesTableExist(in_table_name) THEN
        SELECT CONCAT(
            'Table ',
            in_table_name,
            ' already exists.'
        ) AS message;
    ELSE
        -- Create table with only 'id' column (no constraints yet)
        SET @sql = CONCAT(
            'CREATE TABLE ', in_table_name, ' (',
                'id BIGINT UNSIGNED NOT NULL',
            ')'
        );
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        -- Add primary key constraint on 'id'
        CALL usp_CreatePrimaryKey(in_table_name, 'id', CONCAT('pk_', in_table_name, '.id'));

        -- Make 'id' column AUTO_INCREMENT
        CALL usp_AutoIncrement(in_table_name, 'id');

        -- Add standard columns using usp_AddColumn
        CALL usp_AddColumn(in_table_name, 'internal_id', 'BINARY(16)', 'UUID_TO_BIN(UUID())', TRUE);
        CALL usp_AddColumn(in_table_name, 'created_by', 'BIGINT UNSIGNED', '0', TRUE);
        CALL usp_AddColumn(in_table_name, 'updated_by', 'BIGINT UNSIGNED', NULL, FALSE);
        CALL usp_AddColumn(in_table_name, 'created_at', 'TIMESTAMP', 'UTC_TIMESTAMP', TRUE);
        CALL usp_AddColumn(in_table_name, 'updated_at', 'TIMESTAMP', NULL, FALSE);
        CALL usp_AddColumn(in_table_name, 'void', 'BOOLEAN', '0', FALSE);

        -- Add unique key constraint on 'internal_id'
        CALL usp_CreateUniqueKey(in_table_name, 'internal_id');

        -- Success message
        SELECT CONCAT(
            'Table ',
            in_table_name,
            ' created successfully.'
        ) AS message;
    END IF;
END
$$

DELIMITER ;


-- Script: objects.sql

CALL usp_CreateTable('tblTimeZones');
CALL usp_CreateTable('tblCurrencies');
CALL usp_CreateTable('tblCountries');
CALL usp_CreateTable('tblStates');
CALL usp_CreateTable('tblUsers');
CALL usp_CreateTable('tblUserProfiles');


-- Script: columns.sql

DELIMITER $$

CREATE PROCEDURE usp_CreateColumns_tblCurrencies()
BEGIN
    DECLARE v_required BOOLEAN DEFAULT TRUE;
    DECLARE v_optional BOOLEAN DEFAULT FALSE;

    CALL usp_AddColumn('tblCurrencies', 'iso_code', 'CHAR(3)', NULL, v_required);
    CALL usp_AddColumn('tblCurrencies', 'numeric_code', 'CHAR(3)', NULL, v_optional);
    CALL usp_AddColumn('tblCurrencies', 'name', 'VARCHAR(100)', NULL, v_required);
    CALL usp_AddColumn('tblCurrencies', 'symbol', 'VARCHAR(10)', NULL, v_required);
    CALL usp_AddColumn('tblCurrencies', 'minor_unit', 'TINYINT UNSIGNED', '2', v_required);
END$$

DELIMITER ;

CALL usp_CreateColumns_tblCurrencies();
DROP PROCEDURE usp_CreateColumns_tblCurrencies;


-- Script: constraints.sql

CALL usp_CreateUniqueKey('tblCurrencies', 'iso_code');
CALL usp_CreateUniqueKey('tblCurrencies', 'numeric_code');
CALL usp_CreateUniqueKey('tblCurrencies', 'name');
CALL usp_AddCheck('tblCurrencies', 'iso_code', 'CHAR_LENGTH(`iso_code`) = 3');
CALL usp_AddCheck('tblCurrencies', 'numeric_code', '`numeric_code` IS NULL OR `numeric_code` REGEXP ''^[0-9]{3}$''');


-- Script: data.sql

TRUNCATE TABLE `tblCurrencies`;

ALTER TABLE `tblCurrencies` AUTO_INCREMENT = 1;

INSERT INTO `tblCurrencies`
(
    `iso_code`,
    `numeric_code`,
    `name`,
    `symbol`,
    `minor_unit`
)
VALUES
('AED', NULL, 'United Arab Emirates Dirham', 'د.إ', 2),
('AFN', NULL, 'Afghan Afghani', '؋', 2),
('ALL', NULL, 'Albanian Lek', 'Lek', 2),
('AMD', NULL, 'Armenian Dram', '֏', 2),
('AOA', NULL, 'Angolan Kwanza', 'Kz', 2),
('ARS', NULL, 'Argentine Peso', '$', 2),
('AUD', NULL, 'Australian Dollar', '$', 2),
('AWG', NULL, 'Aruban Florin', 'ƒ', 2),
('AZN', NULL, 'Azerbaijani Manat', '₼', 2),
('BAM', NULL, 'Bosnia and Herzegovina Convertible Mark', 'KM', 2),
('BBD', NULL, 'Barbados Dollar', '$', 2),
('BDT', NULL, 'Bangladeshi Taka', '৳', 2),
('BGN', NULL, 'Bulgarian Lev', 'лв', 2),
('BHD', NULL, 'Bahraini Dinar', 'د.ب', 3),
('BIF', NULL, 'Burundian Franc', 'FBu', 0),
('BMD', NULL, 'Bermudian Dollar', '$', 2),
('BND', NULL, 'Brunei Dollar', 'B$', 2),
('BOB', NULL, 'Bolivian Boliviano', 'Bs.', 2),
('BRL', NULL, 'Brazilian Real', 'R$', 2),
('BSD', NULL, 'Bahamian Dollar', 'B$', 2),
('BTN', NULL, 'Bhutanese Ngultrum', 'Nu.', 2),
('BWP', NULL, 'Botswana Pula', 'P', 2),
('BYN', NULL, 'Belarusian Ruble', 'Br', 2),
('BZD', NULL, 'Belize Dollar', 'BZ$', 2),
('CAD', NULL, 'Canadian Dollar', 'C$', 2),
('CDF', NULL, 'Congolese Franc', 'FC', 2),
('CHF', NULL, 'Swiss Franc', 'CHF', 2),
('CLP', NULL, 'Chilean Peso', '$', 0),
('CNY', NULL, 'Chinese Yuan', '¥', 2),
('COP', NULL, 'Colombian Peso', '$', 2),
('CRC', NULL, 'Costa Rican Colón', '₡', 2),
('CUC', NULL, 'Cuban Convertible Peso', 'CUC$', 2),
('CUP', NULL, 'Cuban Peso', '₱', 2),
('CVE', NULL, 'Cape Verdean Escudo', '$', 2),
('CZK', NULL, 'Czech Koruna', 'Kč', 2),
('DJF', NULL, 'Djiboutian Franc', 'Fdj', 0),
('DKK', NULL, 'Danish Krone', 'kr', 2),
('DOP', NULL, 'Dominican Peso', 'RD$', 2),
('DZD', NULL, 'Algerian Dinar', 'د.ج', 2),
('EGP', NULL, 'Egyptian Pound', 'E£', 2),
('ERN', NULL, 'Eritrean Nakfa', 'Nfk', 2),
('ETB', NULL, 'Ethiopian Birr', 'Br', 2),
('EUR', NULL, 'Euro', '€', 2),
('FJD', NULL, 'Fiji Dollar', '$', 2),
('FKP', NULL, 'Falkland Islands Pound', '£', 2),
('GBP', NULL, 'Pound Sterling', '£', 2),
('GEL', NULL, 'Georgian Lari', '₾', 2),
('GHS', NULL, 'Ghanaian Cedi', '₵', 2),
('GIP', NULL, 'Gibraltar Pound', '£', 2),
('GMD', NULL, 'Gambian Dalasi', 'D', 2),
('GNF', NULL, 'Guinean Franc', 'FG', 0),
('GTQ', NULL, 'Guatemalan Quetzal', 'Q', 2),
('GYD', NULL, 'Guyanese Dollar', '$', 2),
('HKD', NULL, 'Hong Kong Dollar', 'HK$', 2),
('HNL', NULL, 'Honduran Lempira', 'L', 2),
('HRK', NULL, 'Croatian Kuna', 'kn', 2),
('HTG', NULL, 'Haitian Gourde', 'G', 2),
('HUF', NULL, 'Hungarian Forint', 'Ft', 2),
('IDR', NULL, 'Indonesian Rupiah', 'Rp', 2),
('ILS', NULL, 'Israeli New Shekel', '₪', 2),
('INR', NULL, 'Indian Rupee', '₹', 2),
('IQD', NULL, 'Iraqi Dinar', 'ع.د', 3),
('IRR', NULL, 'Iranian Rial', '﷼', 2),
('ISK', NULL, 'Icelandic Króna', 'kr', 0),
('JMD', NULL, 'Jamaican Dollar', 'J$', 2),
('JOD', NULL, 'Jordanian Dinar', 'د.ا', 3),
('JPY', NULL, 'Japanese Yen', '¥', 0),
('KES', NULL, 'Kenyan Shilling', 'KSh', 2),
('KGS', NULL, 'Kyrgyzstani Som', 'с', 2),
('KHR', NULL, 'Cambodian Riel', '៛', 2),
('KMF', NULL, 'Comorian Franc', 'CF', 0),
('KPW', NULL, 'North Korean Won', '₩', 2),
('KRW', NULL, 'South Korean Won', '₩', 0),
('KWD', NULL, 'Kuwaiti Dinar', 'د.ك', 3),
('KYD', NULL, 'Cayman Islands Dollar', '$', 2),
('KZT', NULL, 'Kazakhstani Tenge', '〒', 2),
('LAK', NULL, 'Lao Kip', '₭', 2),
('LBP', NULL, 'Lebanese Pound', 'ل.ل', 2),
('LKR', NULL, 'Sri Lankan Rupee', '₨', 2),
('LRD', NULL, 'Liberian Dollar', 'L$', 2),
('LSL', NULL, 'Lesotho Loti', 'L', 2),
('LYD', NULL, 'Libyan Dinar', 'ل.د', 3),
('MAD', NULL, 'Moroccan Dirham', 'د.م.', 2),
('MDL', NULL, 'Moldovan Leu', 'L', 2),
('MGA', NULL, 'Malagasy Ariary', 'Ar', 2),
('MKD', NULL, 'Macedonian Denar', 'ден', 2),
('MMK', NULL, 'Burmese Kyat', 'Ks', 2),
('MNT', NULL, 'Mongolian Tögrög', '₮', 2),
('MOP', NULL, 'Macanese Pataca', 'P', 2),
('MRU', NULL, 'Mauritanian Ouguiya', 'UM', 2),
('MUR', NULL, 'Mauritian Rupee', '₨', 2),
('MVR', NULL, 'Maldivian Rufiyaa', 'MVR', 2),
('MWK', NULL, 'Malawian Kwacha', 'MK', 2),
('MXN', NULL, 'Mexican Peso', '$', 2),
('MYR', NULL, 'Malaysian Ringgit', 'RM', 2),
('MZN', NULL, 'Mozambican Metical', 'MT', 2),
('NAD', NULL, 'Namibian Dollar', 'N$', 2),
('NGN', NULL, 'Nigerian Naira', '₦', 2),
('NIO', NULL, 'Nicaraguan Córdoba', 'C$', 2),
('NOK', NULL, 'Norwegian Krone', 'kr', 2),
('NPR', NULL, 'Nepalese Rupee', '₨', 2),
('NZD', NULL, 'New Zealand Dollar', 'NZ$', 2),
('OMR', NULL, 'Omani Rial', 'ر.ع.', 3),
('PAB', NULL, 'Panamanian Balboa', 'B/.', 2),
('PEN', NULL, 'Peruvian Sol', 'S/.', 2),
('PGK', NULL, 'Papua New Guinean Kina', 'K', 2),
('PHP', NULL, 'Philippine Peso', '₱', 2),
('PKR', NULL, 'Pakistani Rupee', '₨', 2),
('PLN', NULL, 'Polish Złoty', 'zł', 2),
('PYG', NULL, 'Paraguayan Guaraní', '₲', 0),
('QAR', NULL, 'Qatari Riyal', 'ر.ق', 2),
('RON', NULL, 'Romanian Leu', 'L', 2),
('RSD', NULL, 'Serbian Dinar', 'дин', 2),
('RUB', NULL, 'Russian Ruble', '₽', 2),
('RWF', NULL, 'Rwandan Franc', 'Fr', 0),
('SAR', NULL, 'Saudi Riyal', 'ر.س', 2),
('SBD', NULL, 'Solomon Islands Dollar', '$', 2),
('SCR', NULL, 'Seychellois Rupee', '₨', 2),
('SDG', NULL, 'Sudanese Pound', 'ج.س.', 2),
('SEK', NULL, 'Swedish Krona', 'kr', 2),
('SGD', NULL, 'Singapore Dollar', 'S$', 2),
('SHP', NULL, 'Saint Helena Pound', '£', 2),
('SLE', NULL, 'Sierra Leonean Leone', 'Le', 2),
('SOS', NULL, 'Somali Shilling', 'Sh.So.', 2),
('SRD', NULL, 'Surinamese Dollar', '$', 2),
('SSP', NULL, 'South Sudanese Pound', '£', 2),
('STN', NULL, 'São Tomé and Príncipe Dobra', 'Db', 2),
('SVC', NULL, 'Salvadoran Colón', '₡', 2),
('SYP', NULL, 'Syrian Pound', '£', 2),
('SZL', NULL, 'Swazi Lilangeni', 'L', 2),
('THB', NULL, 'Thai Baht', '฿', 2),
('TJS', NULL, 'Tajikistani Somoni', 'ЅМ', 2),
('TMT', NULL, 'Turkmenistan Manat', 'm', 2),
('TND', NULL, 'Tunisian Dinar', 'د.ت', 3),
('TOP', NULL, 'Tongan Paʻanga', 'T$', 2),
('TRY', NULL, 'Turkish Lira', '₺', 2),
('TTD', NULL, 'Trinidad and Tobago Dollar', 'TT$', 2),
('TWD', NULL, 'New Taiwan Dollar', 'NT$', 2),
('TZS', NULL, 'Tanzanian Shilling', 'TSh', 2),
('UAH', NULL, 'Ukrainian Hryvnia', '₴', 2),
('UGX', NULL, 'Ugandan Shilling', 'Sh', 0),
('USD', NULL, 'United States Dollar', '$', 2),
('UYU', NULL, 'Uruguayan Peso', '$', 2),
('UZS', NULL, 'Uzbekistani Soʻm', 'лв', 2),
('VED', NULL, 'Venezuelan Bolívar', 'Bs.S', 2),
('VND', NULL, 'Vietnamese Đồng', '₫', 0),
('VUV', NULL, 'Vanuatu Vatu', 'VT', 0),
('WST', NULL, 'Samoan Tala', 'T$', 2),
('XAF', NULL, 'Central African CFA Franc', 'FCFA', 0),
('XCD', NULL, 'East Caribbean Dollar', 'EC$', 2),
('XOF', NULL, 'West African CFA Franc', 'CFA', 0),
('XPF', NULL, 'CFP Franc', '₣', 0),
('YER', NULL, 'Yemeni Rial', '﷼', 2),
('ZAR', NULL, 'South African Rand', 'R', 2),
('ZMW', NULL, 'Zambian Kwacha', 'ZK', 2),
('ZWL', NULL, 'Zimbabwean Dollar', 'ZWL$', 2);


-- Script: columns.sql

DELIMITER $$

CREATE PROCEDURE usp_CreateColumns_tblTimeZones()
BEGIN
    DECLARE v_required BOOLEAN DEFAULT TRUE;
    DECLARE v_optional BOOLEAN DEFAULT FALSE;

    CALL usp_AddColumn('tblTimeZones', 'name', 'VARCHAR(100)', NULL, v_required);
    CALL usp_AddColumn('tblTimeZones', 'abbreviation', 'VARCHAR(10)', NULL, v_optional);
    CALL usp_AddColumn('tblTimeZones', 'utc_offset_minutes', 'SMALLINT', NULL, v_required);
    CALL usp_AddColumn('tblTimeZones', 'observes_dst', 'BOOLEAN', '0', v_required);
    CALL usp_AddColumn('tblTimeZones', 'current_offset_minutes', 'SMALLINT', NULL, v_required);
END$$

DELIMITER ;

CALL usp_CreateColumns_tblTimeZones();
DROP PROCEDURE usp_CreateColumns_tblTimeZones;


-- Script: constraints.sql

CALL usp_CreateUniqueKey('tblTimeZones', 'name');
CALL usp_AddCheck('tblTimeZones', 'utc_offset_minutes', '`utc_offset_minutes` BETWEEN -720 AND 840');
CALL usp_AddCheck('tblTimeZones', 'current_offset_minutes', '`current_offset_minutes` BETWEEN -720 AND 840');


-- Script: data.sql

TRUNCATE TABLE `tblTimeZones`;

ALTER TABLE `tblTimeZones` AUTO_INCREMENT = 1;

INSERT INTO `tblTimeZones`
(
    `name`,
    `abbreviation`,
    `utc_offset_minutes`,
    `observes_dst`,
    `current_offset_minutes`
)
VALUES
('Africa/Abidjan', 'GMT', 0, 0, 0),
('Africa/Accra', 'GMT', 0, 0, 0),
('Africa/Algiers', 'CET', 60, 0, 60),
('Africa/Bissau', 'GMT', 0, 0, 0),
('Africa/Cairo', 'EET', 120, 0, 120),
('Africa/Casablanca', '+01', 60, 0, 60),
('Africa/Ceuta', 'CEST', 60, 1, 120),
('Africa/El_Aaiun', '+01', 60, 0, 60),
('Africa/Johannesburg', 'SAST', 120, 0, 120),
('Africa/Juba', 'EAT', 180, 0, 180),
('Africa/Khartoum', 'EAT', 180, 0, 180),
('Africa/Lagos', 'WAT', 60, 0, 60),
('Africa/Maputo', 'CAT', 120, 0, 120),
('Africa/Monrovia', 'GMT', 0, 0, 0),
('Africa/Nairobi', 'EAT', 180, 0, 180),
('Africa/Ndjamena', 'WAT', 60, 0, 60),
('Africa/Sao_Tome', 'GMT', 0, 0, 0),
('Africa/Tripoli', 'EET', 120, 0, 120),
('Africa/Tunis', 'CET', 60, 0, 60),
('Africa/Windhoek', 'CAT', 120, 1, 120),
('America/Adak', 'HDT', -600, 1, -540),
('America/Anchorage', 'AKDT', -540, 1, -480),
('America/Araguaina', 'BRT', -180, 1, -180),
('America/Argentina/Buenos_Aires', 'ART', -180, 0, -180),
('America/Asuncion', '-03', -240, 1, -180),
('America/Atikokan', 'EST', -300, 0, -300),
('America/Bogota', 'COT', -300, 0, -300),
('America/Caracas', 'VET', -240, 0, -240),
('America/Chicago', 'CDT', -360, 1, -300),
('America/Costa_Rica', 'CST', -360, 0, -360),
('America/Denver', 'MDT', -420, 1, -360),
('America/Edmonton', 'MDT', -420, 1, -360),
('America/Halifax', 'ADT', -240, 1, -180),
('America/Hermosillo', 'MST', -420, 0, -420),
('America/Lima', 'PET', -300, 0, -300),
('America/Los_Angeles', 'PDT', -480, 1, -420),
('America/Mexico_City', 'CDT', -360, 1, -300),
('America/Montevideo', 'UYT', -180, 0, -180),
('America/New_York', 'EDT', -300, 1, -240),
('America/Noronha', 'FNT', -120, 0, -120),
('America/Phoenix', 'MST', -420, 0, -420),
('America/Port-au-Prince', 'EST', -300, 1, -240),
('America/Port_of_Spain', 'AST', -240, 0, -240),
('America/Santiago', 'CLST', -240, 1, -180),
('America/Sao_Paulo', 'BRT', -180, 1, -180),
('America/St_Johns', 'NDT', -210, 1, -150),
('America/Tijuana', 'PDT', -480, 1, -420),
('Antarctica/Casey', 'CST', 660, 0, 660),
('Antarctica/Davis', 'DAVT', 420, 0, 420),
('Antarctica/DumontDUrville', 'DDUT', 600, 0, 600),
('Antarctica/Mawson', 'MAWT', 300, 0, 300),
('Antarctica/McMurdo', 'NZDT', 720, 1, 780),
('Antarctica/Rothera', 'ROTT', -180, 0, -180),
('Antarctica/Syowa', 'SYOT', 180, 0, 180),
('Antarctica/Troll', 'CEST', 120, 1, 120),
('Antarctica/Vostok', 'VOST', 360, 0, 360),
('Asia/Almaty', 'ALMT', 360, 0, 360),
('Asia/Amman', 'EET', 120, 1, 180),
('Asia/Anadyr', '+12', 720, 1, 720),
('Asia/Ashgabat', 'TMT', 300, 0, 300),
('Asia/Baghdad', 'AST', 180, 1, 180),
('Asia/Bangkok', 'ICT', 420, 0, 420),
('Asia/Bishkek', 'KGT', 360, 0, 360),
('Asia/Brunei', 'BNT', 480, 0, 480),
('Asia/Colombo', 'IST', 330, 0, 330),
('Asia/Dubai', 'GST', 240, 0, 240),
('Asia/Dushanbe', 'TJT', 300, 0, 300),
('Asia/Ho_Chi_Minh', 'ICT', 420, 0, 420),
('Asia/Hong_Kong', 'HKT', 480, 0, 480),
('Asia/Jakarta', 'WIB', 420, 0, 420),
('Asia/Jerusalem', 'IDT', 120, 1, 180),
('Asia/Kabul', 'AFT', 270, 0, 270),
('Asia/Karachi', 'PKT', 300, 0, 300),
('Asia/Kathmandu', 'NPT', 345, 0, 345),
('Asia/Kolkata', 'IST', 330, 0, 330),
('Asia/Kuala_Lumpur', 'MYT', 480, 0, 480),
('Asia/Manila', 'PST', 480, 0, 480),
('Asia/Nicosia', 'EEST', 120, 1, 180),
('Asia/Qatar', 'AST', 180, 0, 180),
('Asia/Riyadh', 'AST', 180, 0, 180),
('Asia/Seoul', 'KST', 540, 0, 540),
('Asia/Shanghai', 'CST', 480, 0, 480),
('Asia/Singapore', 'SGT', 480, 0, 480),
('Asia/Tehran', 'IRDT', 210, 1, 270),
('Asia/Tokyo', 'JST', 540, 0, 540),
('Atlantic/Azores', 'AZOST', -60, 1, 0),
('Atlantic/Bermuda', 'ADT', -240, 1, -180),
('Atlantic/Canary', 'WEST', 0, 1, 60),
('Atlantic/Cape_Verde', 'CVT', -60, 0, -60),
('Atlantic/Faroe', 'WEST', 0, 1, 60),
('Atlantic/Madeira', 'WEST', 0, 1, 60),
('Atlantic/Reykjavik', 'GMT', 0, 0, 0),
('Atlantic/South_Georgia', 'GST', -120, 0, -120),
('Australia/Brisbane', 'AEST', 600, 0, 600),
('Australia/Darwin', 'ACST', 570, 0, 570),
('Australia/Hobart', 'AEDT', 600, 1, 660),
('Australia/Melbourne', 'AEDT', 600, 1, 660),
('Australia/Perth', 'AWST', 480, 0, 480),
('Australia/Sydney', 'AEDT', 600, 1, 660),
('Europe/Amsterdam', 'CEST', 60, 1, 120),
('Europe/Athens', 'EEST', 120, 1, 180),
('Europe/Berlin', 'CEST', 60, 1, 120),
('Europe/Brussels', 'CEST', 60, 1, 120),
('Europe/Bucharest', 'EEST', 120, 1, 180),
('Europe/Budapest', 'CEST', 60, 1, 120),
('Europe/Copenhagen', 'CEST', 60, 1, 120),
('Europe/Dublin', 'IST', 0, 1, 60),
('Europe/Helsinki', 'EEST', 120, 1, 180),
('Europe/Istanbul', 'TRT', 180, 0, 180),
('Europe/Lisbon', 'WEST', 0, 1, 60),
('Europe/London', 'BST', 0, 1, 60),
('Europe/Madrid', 'CEST', 60, 1, 120),
('Europe/Moscow', 'MSK', 180, 0, 180),
('Europe/Paris', 'CEST', 60, 1, 120),
('Europe/Prague', 'CEST', 60, 1, 120),
('Europe/Rome', 'CEST', 60, 1, 120),
('Europe/Sofia', 'EEST', 120, 1, 180),
('Europe/Stockholm', 'CEST', 60, 1, 120),
('Europe/Tirane', 'CEST', 60, 1, 120),
('Europe/Warsaw', 'CEST', 60, 1, 120),
('Pacific/Apia', 'WST', 780, 1, 780),
('Pacific/Auckland', 'NZST', 720, 1, 780),
('Pacific/Chatham', 'CHAST', 765, 1, 825),
('Pacific/Fakaofo', 'TKT', 780, 0, 780),
('Pacific/Fiji', 'FJT', 720, 1, 720),
('Pacific/Honolulu', 'HST', -600, 0, -600),
('Pacific/Kiritimati', 'LINT', 840, 0, 840),
('Pacific/Pago_Pago', 'SST', -660, 0, -660),
('Pacific/Port_Moresby', 'PGT', 600, 0, 600),
('Pacific/Tahiti', 'TAHT', -600, 0, -600),
('UTC', 'UTC', 0, 0, 0);


-- Script: columns.sql

DELIMITER $$

CREATE PROCEDURE usp_CreateColumns_tblUsers()
BEGIN
    DECLARE v_required BOOLEAN DEFAULT TRUE;
    DECLARE v_optional BOOLEAN DEFAULT FALSE;

    CALL usp_AddColumn('tblUsers', 'firstname', 'VARCHAR(128)', NULL, v_required);
    CALL usp_AddColumn('tblUsers', 'lastname', 'VARCHAR(128)', NULL, v_required);
    CALL usp_AddColumn('tblUsers', 'email', 'VARCHAR(255)', NULL, v_required);
    CALL usp_AddColumn('tblUsers', 'password', 'VARCHAR(255)', NULL, v_required);
END$$

DELIMITER ;

CALL usp_CreateColumns_tblUsers();
DROP PROCEDURE usp_CreateColumns_tblUsers;


-- Script: constraints.sql

CALL usp_CreateUniqueKey('tblUsers', 'email');
CALL usp_AddCheck('tblUsers', 'email', "email REGEXP '^[a-zA-Z0-9][a-zA-Z0-9._-]*@[a-zA-Z0-9][a-zA-Z0-9._-]*\\\\.[a-zA-Z]{2,4}$'");
CALL usp_AddCheck('tblUsers', 'firstname', "TRIM(firstname) <> ''");
CALL usp_AddCheck('tblUsers', 'lastname', "TRIM(lastname) <> ''");
CALL usp_AddCheck('tblUsers', 'password', "password REGEXP '^[a-f0-9]{64}$'");


-- Script: indexes.sql

CALL usp_CreateIndex('tblUsers', 'email');


-- Script: columns.sql

DELIMITER $$

CREATE PROCEDURE usp_CreateColumns_tblCountries()
BEGIN
    DECLARE v_required BOOLEAN DEFAULT TRUE;
    DECLARE v_optional BOOLEAN DEFAULT FALSE;

    CALL usp_AddColumn('tblCountries', 'iso2_code', 'CHAR(2)', NULL, v_required);
    CALL usp_AddColumn('tblCountries', 'iso3_code', 'CHAR(3)', NULL, v_required);
    CALL usp_AddColumn('tblCountries', 'numeric_code', 'CHAR(3)', NULL, v_required);
    CALL usp_AddColumn('tblCountries', 'name', 'VARCHAR(100)', NULL, v_required);
    CALL usp_AddColumn('tblCountries', 'official_name', 'VARCHAR(150)', NULL, v_optional);
    CALL usp_AddColumn('tblCountries', 'capital', 'VARCHAR(100)', NULL, v_optional);
    CALL usp_AddColumn('tblCountries', 'phone_code', 'VARCHAR(50)', NULL, v_optional);
    CALL usp_AddColumn('tblCountries', 'currency_id', 'BIGINT UNSIGNED', NULL, v_optional);
END$$

DELIMITER ;

CALL usp_CreateColumns_tblCountries();
DROP PROCEDURE usp_CreateColumns_tblCountries;


-- Script: constraints.sql

CALL usp_CreateUniqueKey('tblCountries', 'iso2_code');
CALL usp_CreateUniqueKey('tblCountries', 'iso3_code');
CALL usp_CreateUniqueKey('tblCountries', 'numeric_code');
CALL usp_CreateUniqueKey('tblCountries', 'name');

CALL usp_AddCheck('tblCountries', 'iso2_code', '`iso2_code` REGEXP ''^[A-Z]{2}$''');
CALL usp_AddCheck('tblCountries', 'iso3_code', '`iso3_code` REGEXP ''^[A-Z]{3}$''');
CALL usp_AddCheck('tblCountries', 'numeric_code', '`numeric_code` REGEXP ''^[0-9]{3}$''');
CALL usp_AddCheck('tblCountries', 'name', 'CHAR_LENGTH(`name`) > 0');
CALL usp_AddCheck('tblCountries', 'official_name', '`official_name` IS NULL OR CHAR_LENGTH(`official_name`) > 0');
CALL usp_AddCheck('tblCountries', 'capital', '`capital` IS NULL OR CHAR_LENGTH(`capital`) > 0');


-- Script: foreignkeys.sql

CALL usp_CreateForeignKey(
    'tblCountries',
    'currency_id',
    'tblCurrencies',
    'id'
);


-- Script: data.sql

TRUNCATE TABLE `tblCountries`;

ALTER TABLE `tblCountries` AUTO_INCREMENT = 1;

INSERT INTO `tblCountries`
(
    `id`,
    `iso2_code`,
    `iso3_code`, 
    `numeric_code`,
    `name`,
    `official_name`,
    `capital`,
    `phone_code`,
    `currency_id`
)
VALUES
(1, 'AF', 'AFG', '004', 'Afghanistan', 'Islamic Republic of Afghanistan', 'Kabul', '+93', 2),
(2, 'AL', 'ALB', '008', 'Albania', 'Republic of Albania', 'Tirana', '+355', 3),
(3, 'DZ', 'DZA', '012', 'Algeria', 'People''s Democratic Republic of Algeria', 'Algiers', '+213', 39),
(4, 'AD', 'AND', '020', 'Andorra', 'Principality of Andorra', 'Andorra la Vella', '+376', 43),
(5, 'AO', 'AGO', '024', 'Angola', 'Republic of Angola', 'Luanda', '+244', 5),
(6, 'AG', 'ATG', '028', 'Antigua and Barbuda', 'Antigua and Barbuda', 'Saint John''s', '+1-268', 150),
(7, 'AR', 'ARG', '032', 'Argentina', 'Argentine Republic', 'Buenos Aires', '+54', 6),
(8, 'AM', 'ARM', '051', 'Armenia', 'Republic of Armenia', 'Yerevan', '+374', 4),
(9, 'AU', 'AUS', '036', 'Australia', 'Commonwealth of Australia', 'Canberra', '+61', 7),
(10, 'AT', 'AUT', '040', 'Austria', 'Republic of Austria', 'Vienna', '+43', 43),
(11, 'AZ', 'AZE', '031', 'Azerbaijan', 'Republic of Azerbaijan', 'Baku', '+994', 9),
(12, 'BS', 'BHS', '044', 'Bahamas', 'Commonwealth of the Bahamas', 'Nassau', '+1-242', 20),
(13, 'BH', 'BHR', '048', 'Bahrain', 'Kingdom of Bahrain', 'Manama', '+973', 14),
(14, 'BD', 'BGD', '050', 'Bangladesh', 'People''s Republic of Bangladesh', 'Dhaka', '+880', 12),
(15, 'BB', 'BRB', '052', 'Barbados', 'Barbados', 'Bridgetown', '+1-246', 11),
(16, 'BY', 'BLR', '112', 'Belarus', 'Republic of Belarus', 'Minsk', '+375', 23),
(17, 'BE', 'BEL', '056', 'Belgium', 'Kingdom of Belgium', 'Brussels', '+32', 43),
(18, 'BZ', 'BLZ', '084', 'Belize', 'Belize', 'Belmopan', '+501', 24),
(19, 'BJ', 'BEN', '204', 'Benin', 'Republic of Benin', 'Porto-Novo', '+229', 151),
(20, 'BT', 'BTN', '064', 'Bhutan', 'Kingdom of Bhutan', 'Thimphu', '+975', 21),
(21, 'BO', 'BOL', '068', 'Bolivia', 'Plurinational State of Bolivia', 'Sucre', '+591', 18),
(22, 'BA', 'BIH', '070', 'Bosnia and Herzegovina', 'Bosnia and Herzegovina', 'Sarajevo', '+387', 10),
(23, 'BW', 'BWA', '072', 'Botswana', 'Republic of Botswana', 'Gaborone', '+267', 22),
(24, 'BR', 'BRA', '076', 'Brazil', 'Federative Republic of Brazil', 'Brasília', '+55', 19),
(25, 'BN', 'BRN', '096', 'Brunei Darussalam', 'Brunei Darussalam', 'Bandar Seri Begawan', '+673', 17),
(26, 'BG', 'BGR', '100', 'Bulgaria', 'Republic of Bulgaria', 'Sofia', '+359', 13),
(27, 'BF', 'BFA', '854', 'Burkina Faso', 'Burkina Faso', 'Ouagadougou', '+226', 151),
(28, 'BI', 'BDI', '108', 'Burundi', 'Republic of Burundi', 'Gitega', '+257', 15),
(29, 'KH', 'KHM', '116', 'Cambodia', 'Kingdom of Cambodia', 'Phnom Penh', '+855', 70),
(30, 'CM', 'CMR', '120', 'Cameroon', 'Republic of Cameroon', 'Yaoundé', '+237', 149),
(31, 'CA', 'CAN', '124', 'Canada', 'Canada', 'Ottawa', '+1', 25),
(32, 'CV', 'CPV', '132', 'Cape Verde', 'Republic of Cabo Verde', 'Praia', '+238', 34),
(33, 'CF', 'CAF', '140', 'Central African Republic', 'Central African Republic', 'Bangui', '+236', 149),
(34, 'TD', 'TCD', '148', 'Chad', 'Republic of Chad', 'N''Djamena', '+235', 149),
(35, 'CL', 'CHL', '152', 'Chile', 'Republic of Chile', 'Santiago', '+56', 28),
(36, 'CN', 'CHN', '156', 'China', 'People''s Republic of China', 'Beijing', '+86', 29),
(37, 'CO', 'COL', '170', 'Colombia', 'Republic of Colombia', 'Bogotá', '+57', 30),
(38, 'KM', 'COM', '174', 'Comoros', 'Union of the Comoros', 'Moroni', '+269', 71),
(39, 'CG', 'COG', '178', 'Congo', 'Republic of the Congo', 'Brazzaville', '+242', 149),
(40, 'CR', 'CRI', '188', 'Costa Rica', 'Republic of Costa Rica', 'San José', '+506', 31),
(41, 'CI', 'CIV', '384', 'Côte d''Ivoire', 'Republic of Côte d''Ivoire', 'Yamoussoukro', '+225', 151),
(42, 'HR', 'HRV', '191', 'Croatia', 'Republic of Croatia', 'Zagreb', '+385', 56),
(43, 'CU', 'CUB', '192', 'Cuba', 'Republic of Cuba', 'Havana', '+53', 32),
(44, 'CY', 'CYP', '196', 'Cyprus', 'Republic of Cyprus', 'Nicosia', '+357', 43),
(45, 'CZ', 'CZE', '203', 'Czech Republic', 'Czech Republic', 'Prague', '+420', 35),
(46, 'DK', 'DNK', '208', 'Denmark', 'Kingdom of Denmark', 'Copenhagen', '+45', 37),
(47, 'DJ', 'DJI', '262', 'Djibouti', 'Republic of Djibouti', 'Djibouti City', '+253', 36),
(48, 'DM', 'DMA', '212', 'Dominica', 'Commonwealth of Dominica', 'Roseau', '+1-767', 150),
(49, 'DO', 'DOM', '214', 'Dominican Republic', 'Dominican Republic', 'Santo Domingo', '+1-809,1-829,1-849', 38),
(50, 'EC', 'ECU', '218', 'Ecuador', 'Republic of Ecuador', 'Quito', '+593', 142),
(51, 'EG', 'EGY', '818', 'Egypt', 'Arab Republic of Egypt', 'Cairo', '+20', 40),
(52, 'SV', 'SLV', '222', 'El Salvador', 'Republic of El Salvador', 'San Salvador', '+503', 142),
(53, 'GQ', 'GNQ', '226', 'Equatorial Guinea', 'Republic of Equatorial Guinea', 'Malabo', '+240', 149),
(54, 'ER', 'ERI', '232', 'Eritrea', 'State of Eritrea', 'Asmara', '+291', 41),
(55, 'EE', 'EST', '233', 'Estonia', 'Republic of Estonia', 'Tallinn', '+372', 43),
(56, 'SZ', 'SWZ', '748', 'Eswatini', 'Kingdom of Eswatini', 'Mbabane', '+268', 130),
(57, 'ET', 'ETH', '231', 'Ethiopia', 'Federal Democratic Republic of Ethiopia', 'Addis Ababa', '+251', 42),
(58, 'FJ', 'FJI', '242', 'Fiji', 'Republic of Fiji', 'Suva', '+679', 44),
(59, 'FI', 'FIN', '246', 'Finland', 'Republic of Finland', 'Helsinki', '+358', 43),
(60, 'FR', 'FRA', '250', 'France', 'French Republic', 'Paris', '+33', 43),
(61, 'GA', 'GAB', '266', 'Gabon', 'Gabonese Republic', 'Libreville', '+241', 149),
(62, 'GM', 'GMB', '270', 'Gambia', 'Republic of the Gambia', 'Banjul', '+220', 50),
(63, 'GE', 'GEO', '268', 'Georgia', 'Georgia', 'Tbilisi', '+995', 47),
(64, 'DE', 'DEU', '276', 'Germany', 'Federal Republic of Germany', 'Berlin', '+49', 43),
(65, 'GH', 'GHA', '288', 'Ghana', 'Republic of Ghana', 'Accra', '+233', 48),
(66, 'GR', 'GRC', '300', 'Greece', 'Hellenic Republic', 'Athens', '+30', 43),
(67, 'GD', 'GRD', '308', 'Grenada', 'Grenada', 'Saint George''s', '+1-473', 150),
(68, 'GT', 'GTM', '320', 'Guatemala', 'Republic of Guatemala', 'Guatemala City', '+502', 52),
(69, 'GN', 'GIN', '324', 'Guinea', 'Republic of Guinea', 'Conakry', '+224', 51),
(70, 'GW', 'GNB', '624', 'Guinea-Bissau', 'Republic of Guinea-Bissau', 'Bissau', '+245', 151),
(71, 'GY', 'GUY', '328', 'Guyana', 'Co-operative Republic of Guyana', 'Georgetown', '+592', 53),
(72, 'HT', 'HTI', '332', 'Haiti', 'Republic of Haiti', 'Port-au-Prince', '+509', 57),
(73, 'HN', 'HND', '340', 'Honduras', 'Republic of Honduras', 'Tegucigalpa', '+504', 55),
(74, 'HU', 'HUN', '348', 'Hungary', 'Hungary', 'Budapest', '+36', 58),
(75, 'IS', 'ISL', '352', 'Iceland', 'Iceland', 'Reykjavík', '+354', 64),
(76, 'IN', 'IND', '356', 'India', 'Republic of India', 'New Delhi', '+91', 61),
(77, 'ID', 'IDN', '360', 'Indonesia', 'Republic of Indonesia', 'Jakarta', '+62', 59),
(78, 'IR', 'IRN', '364', 'Iran', 'Islamic Republic of Iran', 'Tehran', '+98', 63),
(79, 'IQ', 'IRQ', '368', 'Iraq', 'Republic of Iraq', 'Baghdad', '+964', 62),
(80, 'IE', 'IRL', '372', 'Ireland', 'Ireland', 'Dublin', '+353', 43),
(81, 'IL', 'ISR', '376', 'Israel', 'State of Israel', 'Jerusalem', '+972', 60),
(82, 'IT', 'ITA', '380', 'Italy', 'Italian Republic', 'Rome', '+39', 43),
(83, 'JM', 'JAM', '388', 'Jamaica', 'Jamaica', 'Kingston', '+1-876', 65),
(84, 'JP', 'JPN', '392', 'Japan', 'Japan', 'Tokyo', '+81', 67),
(85, 'JO', 'JOR', '400', 'Jordan', 'Hashemite Kingdom of Jordan', 'Amman', '+962', 66),
(86, 'KZ', 'KAZ', '398', 'Kazakhstan', 'Republic of Kazakhstan', 'Astana', '+7', 76),
(87, 'KE', 'KEN', '404', 'Kenya', 'Republic of Kenya', 'Nairobi', '+254', 68),
(88, 'KI', 'KIR', '296', 'Kiribati', 'Republic of Kiribati', 'South Tarawa', '+686', 7),
(89, 'KW', 'KWT', '414', 'Kuwait', 'State of Kuwait', 'Kuwait City', '+965', 74),
(90, 'KG', 'KGZ', '417', 'Kyrgyzstan', 'Kyrgyz Republic', 'Bishkek', '+996', 69),
(91, 'LA', 'LAO', '418', 'Laos', 'Lao People''s Democratic Republic', 'Vientiane', '+856', 77),
(92, 'LV', 'LVA', '428', 'Latvia', 'Republic of Latvia', 'Riga', '+371', 43),
(93, 'LB', 'LBN', '422', 'Lebanon', 'Lebanese Republic', 'Beirut', '+961', 78),
(94, 'LS', 'LSO', '426', 'Lesotho', 'Kingdom of Lesotho', 'Maseru', '+266', 81),
(95, 'LR', 'LBR', '430', 'Liberia', 'Republic of Liberia', 'Monrovia', '+231', 80),
(96, 'LY', 'LBY', '434', 'Libya', 'State of Libya', 'Tripoli', '+218', 82),
(97, 'LI', 'LIE', '438', 'Liechtenstein', 'Principality of Liechtenstein', 'Vaduz', '+423', 27),
(98, 'LT', 'LTU', '440', 'Lithuania', 'Republic of Lithuania', 'Vilnius', '+370', 43),
(99, 'LU', 'LUX', '442', 'Luxembourg', 'Grand Duchy of Luxembourg', 'Luxembourg City', '+352', 43),
(100, 'MG', 'MDG', '450', 'Madagascar', 'Republic of Madagascar', 'Antananarivo', '+261', 85),
(101, 'MW', 'MWI', '454', 'Malawi', 'Republic of Malawi', 'Lilongwe', '+265', 93),
(102, 'MY', 'MYS', '458', 'Malaysia', 'Malaysia', 'Kuala Lumpur', '+60', 95),
(103, 'MV', 'MDV', '462', 'Maldives', 'Republic of Maldives', 'Malé', '+960', 92),
(104, 'ML', 'MLI', '466', 'Mali', 'Republic of Mali', 'Bamako', '+223', 151),
(105, 'MT', 'MLT', '470', 'Malta', 'Republic of Malta', 'Valletta', '+356', 43),
(106, 'MH', 'MHL', '584', 'Marshall Islands', 'Republic of the Marshall Islands', 'Majuro', '+692', 142),
(107, 'MR', 'MRT', '478', 'Mauritania', 'Islamic Republic of Mauritania', 'Nouakchott', '+222', 90),
(108, 'MU', 'MUS', '480', 'Mauritius', 'Republic of Mauritius', 'Port Louis', '+230', 91),
(109, 'MX', 'MEX', '484', 'Mexico', 'United Mexican States', 'Mexico City', '+52', 94),
(110, 'FM', 'FSM', '583', 'Micronesia', 'Federated States of Micronesia', 'Palikir', '+691', 142),
(111, 'MD', 'MDA', '498', 'Moldova', 'Republic of Moldova', 'Chișinău', '+373', 84),
(112, 'MC', 'MCO', '492', 'Monaco', 'Principality of Monaco', 'Monaco', '+377', 43),
(113, 'MN', 'MNG', '496', 'Mongolia', 'Mongolia', 'Ulaanbaatar', '+976', 88),
(114, 'ME', 'MNE', '499', 'Montenegro', 'Montenegro', 'Podgorica', '+382', 43),
(115, 'MA', 'MAR', '504', 'Morocco', 'Kingdom of Morocco', 'Rabat', '+212', 83),
(116, 'MZ', 'MOZ', '508', 'Mozambique', 'Republic of Mozambique', 'Maputo', '+258', 96),
(117, 'MM', 'MMR', '104', 'Myanmar', 'Republic of the Union of Myanmar', 'Naypyidaw', '+95', 87),
(118, 'NA', 'NAM', '516', 'Namibia', 'Republic of Namibia', 'Windhoek', '+264', 97),
(119, 'NR', 'NRU', '520', 'Nauru', 'Republic of Nauru', 'Yaren', '+674', 7),
(120, 'NP', 'NPL', '524', 'Nepal', 'Federal Democratic Republic of Nepal', 'Kathmandu', '+977', 101),
(121, 'NL', 'NLD', '528', 'Netherlands', 'Kingdom of the Netherlands', 'Amsterdam', '+31', 43),
(122, 'NZ', 'NZL', '554', 'New Zealand', 'New Zealand', 'Wellington', '+64', 102),
(123, 'NI', 'NIC', '558', 'Nicaragua', 'Republic of Nicaragua', 'Managua', '+505', 99),
(124, 'NE', 'NER', '562', 'Niger', 'Republic of the Niger', 'Niamey', '+227', 151),
(125, 'NG', 'NGA', '566', 'Nigeria', 'Federal Republic of Nigeria', 'Abuja', '+234', 98),
(126, 'KP', 'PRK', '408', 'North Korea', 'Democratic People''s Republic of Korea', 'Pyongyang', '+850', 72),
(127, 'MK', 'MKD', '807', 'North Macedonia', 'Republic of North Macedonia', 'Skopje', '+389', 86),
(128, 'NO', 'NOR', '578', 'Norway', 'Kingdom of Norway', 'Oslo', '+47', 100),
(129, 'OM', 'OMN', '512', 'Oman', 'Sultanate of Oman', 'Muscat', '+968', 103),
(130, 'PK', 'PAK', '586', 'Pakistan', 'Islamic Republic of Pakistan', 'Islamabad', '+92', 108),
(131, 'PW', 'PLW', '585', 'Palau', 'Republic of Palau', 'Ngerulmud', '+680', 142),
(132, 'PA', 'PAN', '591', 'Panama', 'Republic of Panama', 'Panama City', '+507', 104),
(133, 'PG', 'PNG', '598', 'Papua New Guinea', 'Independent State of Papua New Guinea', 'Port Moresby', '+675', 106),
(134, 'PY', 'PRY', '600', 'Paraguay', 'Republic of Paraguay', 'Asunción', '+595', 110),
(135, 'PE', 'PER', '604', 'Peru', 'Republic of Peru', 'Lima', '+51', 105),
(136, 'PH', 'PHL', '608', 'Philippines', 'Republic of the Philippines', 'Manila', '+63', 107),
(137, 'PL', 'POL', '616', 'Poland', 'Republic of Poland', 'Warsaw', '+48', 109),
(138, 'PT', 'PRT', '620', 'Portugal', 'Portuguese Republic', 'Lisbon', '+351', 43),
(139, 'QA', 'QAT', '634', 'Qatar', 'State of Qatar', 'Doha', '+974', 111),
(140, 'RO', 'ROU', '642', 'Romania', 'Romania', 'Bucharest', '+40', 112),
(141, 'RU', 'RUS', '643', 'Russia', 'Russian Federation', 'Moscow', '+7', 114),
(142, 'RW', 'RWA', '646', 'Rwanda', 'Republic of Rwanda', 'Kigali', '+250', 115),
(143, 'KN', 'KNA', '659', 'Saint Kitts and Nevis', 'Federation of Saint Kitts and Nevis', 'Basseterre', '+1-869', 150),
(144, 'LC', 'LCA', '662', 'Saint Lucia', 'Saint Lucia', 'Castries', '+1-758', 150),
(145, 'VC', 'VCT', '670', 'Saint Vincent and the Grenadines', 'Saint Vincent and the Grenadines', 'Kingstown', '+1-784', 150),
(146, 'WS', 'WSM', '882', 'Samoa', 'Independent State of Samoa', 'Apia', '+685', 148),
(147, 'SM', 'SMR', '674', 'San Marino', 'Republic of San Marino', 'San Marino', '+378', 43),
(148, 'ST', 'STP', '678', 'Sao Tome and Principe', 'Democratic Republic of Sao Tome and Principe', 'São Tomé', '+239', 127),
(149, 'SA', 'SAU', '682', 'Saudi Arabia', 'Kingdom of Saudi Arabia', 'Riyadh', '+966', 116),
(150, 'SN', 'SEN', '686', 'Senegal', 'Republic of Senegal', 'Dakar', '+221', 151),
(151, 'RS', 'SRB', '688', 'Serbia', 'Republic of Serbia', 'Belgrade', '+381', 113),
(152, 'SC', 'SYC', '690', 'Seychelles', 'Republic of Seychelles', 'Victoria', '+248', 118),
(153, 'SL', 'SLE', '694', 'Sierra Leone', 'Republic of Sierra Leone', 'Freetown', '+232', 123),
(154, 'SG', 'SGP', '702', 'Singapore', 'Republic of Singapore', 'Singapore', '+65', 121),
(155, 'SK', 'SVK', '703', 'Slovakia', 'Slovak Republic', 'Bratislava', '+421', 43),
(156, 'SI', 'SVN', '705', 'Slovenia', 'Republic of Slovenia', 'Ljubljana', '+386', 43),
(157, 'SB', 'SLB', '090', 'Solomon Islands', 'Solomon Islands', 'Honiara', '+677', 117),
(158, 'SO', 'SOM', '706', 'Somalia', 'Federal Republic of Somalia', 'Mogadishu', '+252', 124),
(159, 'ZA', 'ZAF', '710', 'South Africa', 'Republic of South Africa', 'Pretoria', '+27', 154),
(160, 'KR', 'KOR', '410', 'South Korea', 'Republic of Korea', 'Seoul', '+82', 73),
(161, 'SS', 'SSD', '728', 'South Sudan', 'Republic of South Sudan', 'Juba', '+211', 126),
(162, 'ES', 'ESP', '724', 'Spain', 'Kingdom of Spain', 'Madrid', '+34', 43),
(163, 'LK', 'LKA', '144', 'Sri Lanka', 'Democratic Socialist Republic of Sri Lanka', 'Sri Jayawardenepura Kotte', '+94', 79),
(164, 'SD', 'SDN', '729', 'Sudan', 'Republic of the Sudan', 'Khartoum', '+249', 119),
(165, 'SR', 'SUR', '740', 'Suriname', 'Republic of Suriname', 'Paramaribo', '+597', 125),
(166, 'SE', 'SWE', '752', 'Sweden', 'Kingdom of Sweden', 'Stockholm', '+46', 120),
(167, 'CH', 'CHE', '756', 'Switzerland', 'Swiss Confederation', 'Bern', '+41', 27),
(168, 'SY', 'SYR', '760', 'Syria', 'Syrian Arab Republic', 'Damascus', '+963', 129),
(169, 'TW', 'TWN', '158', 'Taiwan', 'Republic of China', 'Taipei', '+886', 138),
(170, 'TJ', 'TJK', '762', 'Tajikistan', 'Republic of Tajikistan', 'Dushanbe', '+992', 132),
(171, 'TZ', 'TZA', '834', 'Tanzania', 'United Republic of Tanzania', 'Dodoma', '+255', 139),
(172, 'TH', 'THA', '764', 'Thailand', 'Kingdom of Thailand', 'Bangkok', '+66', 131),
(173, 'TG', 'TGO', '768', 'Togo', 'Togolese Republic', 'Lomé', '+228', 151),
(174, 'TO', 'TON', '776', 'Tonga', 'Kingdom of Tonga', 'Nukuʻalofa', '+676', 135),
(175, 'TT', 'TTO', '780', 'Trinidad and Tobago', 'Republic of Trinidad and Tobago', 'Port of Spain', '+1-868', 137),
(176, 'TN', 'TUN', '788', 'Tunisia', 'Republic of Tunisia', 'Tunis', '+216', 134),
(177, 'TR', 'TUR', '792', 'Turkey', 'Republic of Türkiye', 'Ankara', '+90', 136),
(178, 'TM', 'TKM', '795', 'Turkmenistan', 'Turkmenistan', 'Ashgabat', '+993', 133),
(179, 'TV', 'TUV', '798', 'Tuvalu', 'Tuvalu', 'Funafuti', '+688', 7),
(180, 'UG', 'UGA', '800', 'Uganda', 'Republic of Uganda', 'Kampala', '+256', 141),
(181, 'UA', 'UKR', '804', 'Ukraine', 'Ukraine', 'Kyiv', '+380', 140),
(182, 'AE', 'ARE', '784', 'United Arab Emirates', 'United Arab Emirates', 'Abu Dhabi', '+971', 1),
(183, 'GB', 'GBR', '826', 'United Kingdom', 'United Kingdom of Great Britain and Northern Ireland', 'London', '+44', 46),
(184, 'US', 'USA', '840', 'United States', 'United States of America', 'Washington, D.C.', '+1', 142),
(185, 'UY', 'URY', '858', 'Uruguay', 'Oriental Republic of Uruguay', 'Montevideo', '+598', 143),
(186, 'UZ', 'UZB', '860', 'Uzbekistan', 'Republic of Uzbekistan', 'Tashkent', '+998', 144),
(187, 'VU', 'VUT', '548', 'Vanuatu', 'Republic of Vanuatu', 'Port Vila', '+678', 147),
(188, 'VA', 'VAT', '336', 'Vatican City', 'Vatican City State', 'Vatican City', '+379', 43),
(189, 'VE', 'VEN', '862', 'Venezuela', 'Bolivarian Republic of Venezuela', 'Caracas', '+58', 145),
(190, 'VN', 'VNM', '704', 'Vietnam', 'Socialist Republic of Vietnam', 'Hanoi', '+84', 146),
(191, 'YE', 'YEM', '887', 'Yemen', 'Republic of Yemen', 'Sana''a', '+967', 153),
(192, 'ZM', 'ZMB', '894', 'Zambia', 'Republic of Zambia', 'Lusaka', '+260', 155),
(193, 'ZW', 'ZWE', '716', 'Zimbabwe', 'Republic of Zimbabwe', 'Harare', '+263', 156);



-- Script: columns.sql

DELIMITER $$

CREATE PROCEDURE usp_CreateColumns_tblStates()
BEGIN
    DECLARE v_required BOOLEAN DEFAULT TRUE;
    DECLARE v_optional BOOLEAN DEFAULT FALSE;

    CALL usp_AddColumn('tblStates', 'name', 'VARCHAR(255)', NULL, v_required);
    CALL usp_AddColumn('tblStates', 'official_name', 'VARCHAR(150)', NULL, v_optional);
    CALL usp_AddColumn('tblStates', 'iso_code', 'VARCHAR(10)', NULL, v_required);
    CALL usp_AddColumn('tblStates', 'capital', 'VARCHAR(100)', NULL, v_optional);
    CALL usp_AddColumn('tblStates', 'timezone_id', 'BIGINT UNSIGNED', NULL, v_required);
    CALL usp_AddColumn('tblStates', 'phone_code', 'VARCHAR(10)', NULL, v_optional);
    CALL usp_AddColumn('tblStates', 'country_id', 'BIGINT UNSIGNED', NULL, v_required);
END$$

DELIMITER ;

CALL usp_CreateColumns_tblStates();
DROP PROCEDURE usp_CreateColumns_tblStates;


-- Script: constraints.sql

CALL usp_CreateUniqueKey('tblStates', 'country_id, iso_code');
CALL usp_CreateUniqueKey('tblStates', 'country_id, name');
CALL usp_AddCheck('tblStates', 'phone_code', '`phone_code` IS NULL OR phone_code REGEXP ''^\\+[0-9]+$''');


-- Script: foreignkeys.sql

CALL usp_CreateForeignKey(
    'tblStates',
    'country_id',
    'tblCountries',
    'id'
);

CALL usp_CreateForeignKey(
    'tblStates',
    'timezone_id',
    'tblTimeZones',
    'id'
);


-- Script: data.sql

TRUNCATE TABLE `tblStates`;

ALTER TABLE `tblStates` AUTO_INCREMENT = 1;

INSERT INTO `tblStates`
(
    `name`,
    `iso_code`,
    `capital`,
    `timezone_id`,
    `country_id`
)
VALUES
-- Australia States (Country ID: 9)
('New South Wales', 'NSW', 'Sydney', 111, 9),
('Victoria', 'VIC', 'Melbourne', 109, 9),
('Queensland', 'QLD', 'Brisbane', 106, 9),
('Western Australia', 'WA', 'Perth', 110, 9),
('South Australia', 'SA', 'Adelaide', 107, 9), -- Mapped to Darwin TZ as proxy for Adelaide TZ
('Tasmania', 'TAS', 'Hobart', 108, 9),
('Australian Capital Territory', 'ACT', 'Canberra', 111, 9),
('Northern Territory', 'NT', 'Darwin', 107, 9),

-- Canada Provinces and Territories (Country ID: 31)
('Ontario', 'ON', 'Toronto', 40, 31),
('Quebec', 'QC', 'Quebec City', 40, 31),
('Nova Scotia', 'NS', 'Halifax', 34, 31),
('New Brunswick', 'NB', 'Fredericton', 34, 31),
('Manitoba', 'MB', 'Winnipeg', 30, 31),
('British Columbia', 'BC', 'Victoria', 37, 31),
('Prince Edward Island', 'PE', 'Charlottetown', 34, 31),
('Saskatchewan', 'SK', 'Regina', 30, 31),
('Alberta', 'AB', 'Edmonton', 33, 31),
('Newfoundland and Labrador', 'NL', 'St. John''s', 48, 31),
('Northwest Territories', 'NT', 'Yellowknife', 33, 31),
('Yukon', 'YT', 'Whitehorse', 33, 31),
('Nunavut', 'NU', 'Iqaluit', 40, 31),

-- India States and Union Territories (Country ID: 76)
('Andhra Pradesh', 'AP', 'Amaravati', 80, 76),
('Arunachal Pradesh', 'AR', 'Itanagar', 80, 76),
('Assam', 'AS', 'Dispur', 80, 76),
('Bihar', 'BR', 'Patna', 80, 76),
('Chhattisgarh', 'CG', 'Raipur', 80, 76),
('Goa', 'GA', 'Panaji', 80, 76),
('Gujarat', 'GJ', 'Gandhinagar', 80, 76),
('Haryana', 'HR', 'Chandigarh', 80, 76),
('Himachal Pradesh', 'HP', 'Shimla', 80, 76),
('Jharkhand', 'JH', 'Ranchi', 80, 76),
('Karnataka', 'KA', 'Bengaluru', 80, 76),
('Kerala', 'KL', 'Thiruvananthapuram', 80, 76),
('Madhya Pradesh', 'MP', 'Bhopal', 80, 76),
('Maharashtra', 'MH', 'Mumbai', 80, 76),
('Manipur', 'MN', 'Imphal', 80, 76),
('Meghalaya', 'ML', 'Shillong', 80, 76),
('Mizoram', 'MZ', 'Aizawl', 80, 76),
('Nagaland', 'NL', 'Kohima', 80, 76),
('Odisha', 'OR', 'Bhubaneswar', 80, 76),
('Punjab', 'PB', 'Chandigarh', 80, 76),
('Rajasthan', 'RJ', 'Jaipur', 80, 76),
('Sikkim', 'SK', 'Gangtok', 80, 76),
('Tamil Nadu', 'TN', 'Chennai', 80, 76),
('Telangana', 'TG', 'Hyderabad', 80, 76),
('Tripura', 'TR', 'Agartala', 80, 76),
('Uttar Pradesh', 'UP', 'Lucknow', 80, 76),
('Uttarakhand', 'UT', 'Dehradun', 80, 76),
('West Bengal', 'WB', 'Kolkata', 80, 76),
('Andaman and Nicobar Islands', 'AN', 'Port Blair', 80, 76),
('Chandigarh', 'CH', 'Chandigarh', 80, 76),
('Dadra and Nagar Haveli and Daman and Diu', 'DD', 'Daman', 80, 76),
('Delhi', 'DL', 'New Delhi', 80, 76),
('Jammu and Kashmir', 'JK', 'Srinagar', 80, 76),
('Ladakh', 'LA', 'Leh', 80, 76),
('Lakshadweep', 'LD', 'Kavaratti', 80, 76),
('Puducherry', 'PY', 'Pondicherry', 80, 76),

-- United Kingdom Countries (Country ID: 183)
('England', 'ENG', 'London', 117, 183),
('Scotland', 'SCT', 'Edinburgh', 117, 183),
('Wales', 'WLS', 'Cardiff', 117, 183),
('Northern Ireland', 'NIR', 'Belfast', 117, 183),

-- United States States (Country ID: 184)
('Alabama', 'AL', 'Montgomery', 29, 184),
('Alaska', 'AK', 'Juneau', 22, 184),
('Arizona', 'AZ', 'Phoenix', 41, 184),
('Arkansas', 'AR', 'Little Rock', 29, 184),
('California', 'CA', 'Sacramento', 36, 184),
('Colorado', 'CO', 'Denver', 31, 184),
('Connecticut', 'CT', 'Hartford', 39, 184),
('Delaware', 'DE', 'Dover', 39, 184),
('Florida', 'FL', 'Tallahassee', 39, 184),
('Georgia', 'GA', 'Atlanta', 39, 184),
('Hawaii', 'HI', 'Honolulu', 141, 184),
('Idaho', 'ID', 'Boise', 31, 184),
('Illinois', 'IL', 'Springfield', 29, 184),
('Indiana', 'IN', 'Indianapolis', 39, 184),
('Iowa', 'IA', 'Des Moines', 29, 184),
('Kansas', 'KS', 'Topeka', 29, 184),
('Kentucky', 'KY', 'Frankfort', 39, 184),
('Louisiana', 'LA', 'Baton Rouge', 29, 184),
('Maine', 'ME', 'Augusta', 39, 184),
('Maryland', 'MD', 'Annapolis', 39, 184),
('Massachusetts', 'MA', 'Boston', 39, 184),
('Michigan', 'MI', 'Lansing', 39, 184),
('Minnesota', 'MN', 'Saint Paul', 29, 184),
('Mississippi', 'MS', 'Jackson', 29, 184),
('Missouri', 'MO', 'Jefferson City', 29, 184),
('Montana', 'MT', 'Helena', 31, 184),
('Nebraska', 'NE', 'Lincoln', 29, 184),
('Nevada', 'NV', 'Carson City', 36, 184),
('New Hampshire', 'NH', 'Concord', 39, 184),
('New Jersey', 'NJ', 'Trenton', 39, 184),
('New Mexico', 'NM', 'Santa Fe', 31, 184),
('New York', 'NY', 'Albany', 39, 184),
('North Carolina', 'NC', 'Raleigh', 39, 184),
('North Dakota', 'ND', 'Bismarck', 29, 184),
('Ohio', 'OH', 'Columbus', 39, 184),
('Oklahoma', 'OK', 'Oklahoma City', 29, 184),
('Oregon', 'OR', 'Salem', 36, 184),
('Pennsylvania', 'PA', 'Harrisburg', 39, 184),
('Rhode Island', 'RI', 'Providence', 39, 184),
('South Carolina', 'SC', 'Columbia', 39, 184),
('South Dakota', 'SD', 'Pierre', 29, 184),
('Tennessee', 'TN', 'Nashville', 29, 184),
('Texas', 'TX', 'Austin', 29, 184),
('Utah', 'UT', 'Salt Lake City', 31, 184),
('Vermont', 'VT', 'Montpelier', 39, 184),
('Virginia', 'VA', 'Richmond', 39, 184),
('Washington', 'WA', 'Olympia', 36, 184),
('West Virginia', 'WV', 'Charleston', 39, 184),
('Wisconsin', 'WI', 'Madison', 29, 184),
('Wyoming', 'WY', 'Cheyenne', 31, 184);

INSERT INTO `tblStates` (`name`, `iso_code`, `capital`, `timezone_id`, `country_id`) VALUES
-- Germany States (Country ID: 64, Timezone ID: 114 'Europe/Berlin')
('Baden-Württemberg', 'BW', 'Stuttgart', 114, 64),
('Bavaria', 'BY', 'Munich', 114, 64),
('Berlin', 'BE', 'Berlin', 114, 64),
('Brandenburg', 'BB', 'Potsdam', 114, 64),
('Bremen', 'HB', 'Bremen', 114, 64),
('Hamburg', 'HH', 'Hamburg', 114, 64),
('Hesse', 'HE', 'Wiesbaden', 114, 64),
('Lower Saxony', 'NI', 'Hanover', 114, 64),
('Mecklenburg-Vorpommern', 'MV', 'Schwerin', 114, 64),
('North Rhine-Westphalia', 'NW', 'Düsseldorf', 114, 64),
('Rhineland-Palatinate', 'RP', 'Mainz', 114, 64),
('Saarland', 'SL', 'Saarbrücken', 114, 64),
('Saxony', 'SN', 'Dresden', 114, 64),
('Saxony-Anhalt', 'ST', 'Magdeburg', 114, 64),
('Schleswig-Holstein', 'SH', 'Kiel', 114, 64),
('Thuringia', 'TH', 'Erfurt', 114, 64),

-- France Regions (Country ID: 60, Timezone ID: 127 'Europe/Paris')
('Auvergne-Rhône-Alpes', 'ARA', 'Lyon', 127, 60),
('Bourgogne-Franche-Comté', 'BFC', 'Dijon', 127, 60),
('Brittany', 'BRE', 'Rennes', 127, 60),
('Centre-Val de Loire', 'CVL', 'Orléans', 127, 60),
('Corsica', 'COR', 'Ajaccio', 127, 60),
('Grand Est', 'GES', 'Strasbourg', 127, 60),
('Hauts-de-France', 'HDF', 'Lille', 127, 60),
('Île-de-France', 'IDF', 'Paris', 127, 60),
('Normandy', 'NOR', 'Rouen', 127, 60),
('Nouvelle-Aquitaine', 'NAQ', 'Bordeaux', 127, 60),
('Occitanie', 'OCC', 'Toulouse', 127, 60),
('Pays de la Loire', 'PDL', 'Nantes', 127, 60),
('Provence-Alpes-Côte d''Azur', 'PAC', 'Marseille', 127, 60),

-- Brazil States (Country ID: 24, Timezone ID: 47 'America/Sao_Paulo' as primary)
('Acre', 'AC', 'Rio Branco', 47, 24),
('Alagoas', 'AL', 'Maceió', 47, 24),
('Amapá', 'AP', 'Macapá', 47, 24),
('Amazonas', 'AM', 'Manaus', 47, 24),
('Bahia', 'BA', 'Salvador', 47, 24),
('Ceará', 'CE', 'Fortaleza', 47, 24),
('Distrito Federal', 'DF', 'Brasília', 47, 24),
('Espírito Santo', 'ES', 'Vitória', 47, 24),
('Goiás', 'GO', 'Goiânia', 47, 24),
('Maranhão', 'MA', 'São Luís', 47, 24),
('Mato Grosso', 'MT', 'Cuiabá', 47, 24),
('Mato Grosso do Sul', 'MS', 'Campo Grande', 47, 24),
('Minas Gerais', 'MG', 'Belo Horizonte', 47, 24),
('Pará', 'PA', 'Belém', 47, 24),
('Paraíba', 'PB', 'João Pessoa', 47, 24),
('Paraná', 'PR', 'Curitiba', 47, 24),
('Pernambuco', 'PE', 'Recife', 47, 24),
('Piauí', 'PI', 'Teresina', 47, 24),
('Rio de Janeiro', 'RJ', 'Rio de Janeiro', 47, 24),
('Rio Grande do Norte', 'RN', 'Natal', 47, 24),
('Rio Grande do Sul', 'RS', 'Porto Alegre', 47, 24),
('Rondônia', 'RO', 'Porto Velho', 47, 24),
('Roraima', 'RR', 'Boa Vista', 47, 24),
('Santa Catarina', 'SC', 'Florianópolis', 47, 24),
('São Paulo', 'SP', 'São Paulo', 47, 24),
('Sergipe', 'SE', 'Aracaju', 47, 24),
('Tocantins', 'TO', 'Palmas', 47, 24),

-- China Provinces (Country ID: 36, Timezone ID: 88 'Asia/Shanghai')
('Anhui', 'AH', 'Hefei', 88, 36),
('Beijing', 'BJ', 'Beijing', 88, 36),
('Chongqing', 'CQ', 'Chongqing', 88, 36),
('Fujian', 'FJ', 'Fuzhou', 88, 36),
('Gansu', 'GS', 'Lanzhou', 88, 36),
('Guangdong', 'GD', 'Guangzhou', 88, 36),
('Guangxi', 'GX', 'Nanning', 88, 36),
('Guizhou', 'GZ', 'Guiyang', 88, 36),
('Hainan', 'HI', 'Haikou', 88, 36),
('Hebei', 'HE', 'Shijiazhuang', 88, 36),
('Heilongjiang', 'HL', 'Harbin', 88, 36),
('Henan', 'HA', 'Zhengzhou', 88, 36),
('Hong Kong', 'HK', 'Hong Kong', 88, 36),
('Hubei', 'HB', 'Wuhan', 88, 36),
('Hunan', 'HN', 'Changsha', 88, 36),
('Inner Mongolia', 'NM', 'Hohhot', 88, 36),
('Jiangsu', 'JS', 'Nanjing', 88, 36),
('Jiangxi', 'JX', 'Nanchang', 88, 36),
('Jilin', 'JL', 'Changchun', 88, 36),
('Liaoning', 'LN', 'Shenyang', 88, 36),
('Macau', 'MO', 'Macau', 88, 36),
('Ningxia', 'NX', 'Yinchuan', 88, 36),
('Qinghai', 'QH', 'Xining', 88, 36),
('Shaanxi', 'SN', 'Xi''an', 88, 36),
('Shandong', 'SD', 'Jinan', 88, 36),
('Shanghai', 'SH', 'Shanghai', 88, 36),
('Shanxi', 'SX', 'Taiyuan', 88, 36),
('Sichuan', 'SC', 'Chengdu', 88, 36),
('Tianjin', 'TJ', 'Tianjin', 88, 36),
('Tibet', 'XZ', 'Lhasa', 88, 36),
('Xinjiang', 'XJ', 'Ürümqi', 88, 36),
('Yunnan', 'YN', 'Kunming', 88, 36),
('Zhejiang', 'ZJ', 'Hangzhou', 88, 36),

-- Japan Prefectures (Country ID: 84, Timezone ID: 92 'Asia/Tokyo')
('Hokkaido', '01', 'Sapporo', 92, 84),
('Aomori', '02', 'Aomori', 92, 84),
('Iwate', '03', 'Morioka', 92, 84),
('Miyagi', '04', 'Sendai', 92, 84),
('Akita', '05', 'Akita', 92, 84),
('Yamagata', '06', 'Yamagata', 92, 84),
('Fukushima', '07', 'Fukushima', 92, 84),
('Ibaraki', '08', 'Mito', 92, 84),
('Tochigi', '09', 'Utsunomiya', 92, 84),
('Gunma', '10', 'Maebashi', 92, 84),
('Saitama', '11', 'Saitama', 92, 84),
('Chiba', '12', 'Chiba', 92, 84),
('Tokyo', '13', 'Tokyo', 92, 84),
('Kanagawa', '14', 'Yokohama', 92, 84),
('Niigata', '15', 'Niigata', 92, 84),
('Toyama', '16', 'Toyama', 92, 84),
('Ishikawa', '17', 'Kanazawa', 92, 84),
('Fukui', '18', 'Fukui', 92, 84),
('Yamanashi', '19', 'Kofu', 92, 84),
('Nagano', '20', 'Nagano', 92, 84),
('Gifu', '21', 'Gifu', 92, 84),
('Shizuoka', '22', 'Shizuoka', 92, 84),
('Aichi', '23', 'Nagoya', 92, 84),
('Mie', '24', 'Tsu', 92, 84),
('Shiga', '25', 'Otsu', 92, 84),
('Kyoto', '26', 'Kyoto', 92, 84),
('Osaka', '27', 'Osaka', 92, 84),
('Hyogo', '28', 'Kobe', 92, 84),
('Nara', '29', 'Nara', 92, 84),
('Wakayama', '30', 'Wakayama', 92, 84),
('Tottori', '31', 'Tottori', 92, 84),
('Shimane', '32', 'Matsue', 92, 84),
('Okayama', '33', 'Okayama', 92, 84),
('Hiroshima', '34', 'Hiroshima', 92, 84),
('Yamaguchi', '35', 'Yamaguchi', 92, 84),
('Tokushima', '36', 'Tokushima', 92, 84),
('Kagawa', '37', 'Takamatsu', 92, 84),
('Ehime', '38', 'Matsuyama', 92, 84),
('Kochi', '39', 'Kochi', 92, 84),
('Fukuoka', '40', 'Fukuoka', 92, 84),
('Saga', '41', 'Saga', 92, 84),
('Nagasaki', '42', 'Nagasaki', 92, 84),
('Kumamoto', '43', 'Kumamoto', 92, 84),
('Oita', '44', 'Oita', 92, 84),
('Miyazaki', '45', 'Miyazaki', 92, 84),
('Kagoshima', '46', 'Kagoshima', 92, 84),
('Okinawa', '47', 'Naha', 92, 84),

-- Nigeria States (Country ID: 125, Timezone ID: 12 'Africa/Lagos')
('Abia', 'AB', 'Umuahia', 12, 125),
('Adamawa', 'AD', 'Yola', 12, 125),
('Akwa Ibom', 'AK', 'Uyo', 12, 125),
('Anambra', 'AN', 'Awka', 12, 125),
('Bauchi', 'BA', 'Bauchi', 12, 125),
('Bayelsa', 'BY', 'Yenagoa', 12, 125),
('Benue', 'BE', 'Makurdi', 12, 125),
('Borno', 'BO', 'Maiduguri', 12, 125),
('Cross River', 'CR', 'Calabar', 12, 125),
('Delta', 'DE', 'Asaba', 12, 125),
('Ebonyi', 'EB', 'Abakaliki', 12, 125),
('Edo', 'ED', 'Benin City', 12, 125),
('Ekiti', 'EK', 'Ado Ekiti', 12, 125),
('Enugu', 'EN', 'Enugu', 12, 125),
('Federal Capital Territory', 'FC', 'Abuja', 12, 125),
('Gombe', 'GO', 'Gombe', 12, 125),
('Imo', 'IM', 'Owerri', 12, 125),
('Jigawa', 'JI', 'Dutse', 12, 125),
('Kaduna', 'KD', 'Kaduna', 12, 125),
('Kano', 'KN', 'Kano', 12, 125),
('Katsina', 'KT', 'Katsina', 12, 125),
('Kebbi', 'KE', 'Birnin Kebbi', 12, 125),
('Kogi', 'KO', 'Lokoja', 12, 125),
('Kwara', 'KW', 'Ilorin', 12, 125),
('Lagos', 'LA', 'Ikeja', 12, 125),
('Nasarawa', 'NA', 'Lafia', 12, 125),
('Niger', 'NI', 'Minna', 12, 125),
('Ogun', 'OG', 'Abeokuta', 12, 125),
('Ondo', 'ON', 'Akure', 12, 125),
('Osun', 'OS', 'Osogbo', 12, 125),
('Oyo', 'OY', 'Ibadan', 12, 125),
('Plateau', 'PL', 'Jos', 12, 125),
('Rivers', 'RI', 'Port Harcourt', 12, 125),
('Sokoto', 'SO', 'Sokoto', 12, 125),
('Taraba', 'TA', 'Jalingo', 12, 125),
('Yobe', 'YO', 'Damaturu', 12, 125),
('Zamfara', 'ZA', 'Gusau', 12, 125);

INSERT INTO `tblStates` (`name`, `iso_code`, `capital`, `timezone_id`, `country_id`) VALUES
-- Afghanistan Provinces (Country ID: 1, Timezone ID: 77 'Asia/Kabul')
('Badakhshan', 'BDS', 'Fayzabad', 77, 1),
('Badghis', 'BDG', 'Qala i Naw', 77, 1),
('Baghlan', 'BGL', 'Puli Khumri', 77, 1),
('Balkh', 'BAL', 'Mazar-i-Sharif', 77, 1),
('Bamyan', 'BAM', 'Bamyan', 77, 1),
('Daykundi', 'DAY', 'Nili', 77, 1),
('Farah', 'FRA', 'Farah', 77, 1),
('Faryab', 'FYB', 'Maymana', 77, 1),
('Ghazni', 'GHA', 'Ghazni', 77, 1),
('Ghor', 'GHO', 'Chaghcharan', 77, 1),
('Helmand', 'HEL', 'Lashkargah', 77, 1),
('Herat', 'HER', 'Herat', 77, 1),
('Jowzjan', 'JOW', 'Sheberghan', 77, 1),
('Kabul', 'KAB', 'Kabul', 77, 1),
('Kandahar', 'KAN', 'Kandahar', 77, 1),
('Kapisa', 'KAP', 'Mahmud-i-Raqi', 77, 1),
('Khost', 'KHO', 'Khost', 77, 1),
('Kunar', 'KNR', 'Asadabad', 77, 1),
('Kunduz', 'KDZ', 'Kunduz', 77, 1),
('Laghman', 'LAG', 'Mihtarlam', 77, 1),
('Logar', 'LOG', 'Pul-i-Alam', 77, 1),
('Nangarhar', 'NAN', 'Jalalabad', 77, 1),
('Nimruz', 'NIM', 'Zaranj', 77, 1),
('Nuristan', 'NUR', 'Parun', 77, 1),
('Paktia', 'PIA', 'Gardez', 77, 1),
('Paktika', 'PKA', 'Sharan', 77, 1),
('Panjshir', 'PAN', 'Bazarak', 77, 1),
('Parwan', 'PAR', 'Charikar', 77, 1),
('Samangan', 'SAM', 'Aybak', 77, 1),
('Sar-e Pol', 'SAR', 'Sar-e Pol', 77, 1),
('Takhar', 'TAK', 'Taloqan', 77, 1),
('Urozgan', 'URU', 'Tarinkot', 77, 1),
('Wardak', 'WAR', 'Maidan Shar', 77, 1),
('Zabul', 'ZAB', 'Qalat', 77, 1),

-- Albania Counties (Country ID: 2, Timezone ID: 133 'Europe/Tirane')
('Berat', '01', 'Berat', 133, 2),
('Dibër', '09', 'Peshkopi', 133, 2),
('Durrës', '02', 'Durrës', 133, 2),
('Elbasan', '03', 'Elbasan', 133, 2),
('Fier', '04', 'Fier', 133, 2),
('Gjirokastër', '05', 'Gjirokastër', 133, 2),
('Korçë', '06', 'Korçë', 133, 2),
('Kukës', '07', 'Kukës', 133, 2),
('Lezhë', '08', 'Lezhë', 133, 2),
('Shkodër', '10', 'Shkodër', 133, 2),
('Tirana', '11', 'Tirana', 133, 2),
('Vlorë', '12', 'Vlorë', 133, 2),

-- Algeria Provinces (Country ID: 3, Timezone ID: 3 'Africa/Algiers')
('Adrar', '01', 'Adrar', 3, 3),
('Chlef', '02', 'Chlef', 3, 3),
('Laghouat', '03', 'Laghouat', 3, 3),
('Oum El Bouaghi', '04', 'Oum El Bouaghi', 3, 3),
('Batna', '05', 'Batna', 3, 3),
('Béjaïa', '06', 'Béjaïa', 3, 3),
('Biskra', '07', 'Biskra', 3, 3),
('Béchar', '08', 'Béchar', 3, 3),
('Blida', '09', 'Blida', 3, 3),
('Bouira', '10', 'Bouira', 3, 3),
('Tamanrasset', '11', 'Tamanrasset', 3, 3),
('Tébessa', '12', 'Tébessa', 3, 3),
('Tlemcen', '13', 'Tlemcen', 3, 3),
('Tiaret', '14', 'Tiaret', 3, 3),
('Tizi Ouzou', '15', 'Tizi Ouzou', 3, 3),
('Algiers', '16', 'Algiers', 3, 3),
('Djelfa', '17', 'Djelfa', 3, 3),
('Jijel', '18', 'Jijel', 3, 3),
('Sétif', '19', 'Sétif', 3, 3),
('Saïda', '20', 'Saïda', 3, 3),
('Skikda', '21', 'Skikda', 3, 3),
('Sidi Bel Abbès', '22', 'Sidi Bel Abbès', 3, 3),
('Annaba', '23', 'Annaba', 3, 3),
('Guelma', '24', 'Guelma', 3, 3),
('Constantine', '25', 'Constantine', 3, 3),
('Médéa', '26', 'Médéa', 3, 3),
('Mostaganem', '27', 'Mostaganem', 3, 3),
('M''Sila', '28', 'M''Sila', 3, 3),
('Mascara', '29', 'Mascara', 3, 3),
('Ouargla', '30', 'Ouargla', 3, 3),
('Oran', '31', 'Oran', 3, 3),
('El Bayadh', '32', 'El Bayadh', 3, 3),
('Illizi', '33', 'Illizi', 3, 3),
('Bordj Bou Arréridj', '34', 'Bordj Bou Arréridj', 3, 3),
('Boumerdès', '35', 'Boumerdès', 3, 3),
('El Tarf', '36', 'El Tarf', 3, 3),
('Tindouf', '37', 'Tindouf', 3, 3),
('Tissemsilt', '38', 'Tissemsilt', 3, 3),
('El Oued', '39', 'El Oued', 3, 3),
('Khenchela', '40', 'Khenchela', 3, 3),
('Souk Ahras', '41', 'Souk Ahras', 3, 3),
('Tipaza', '42', 'Tipaza', 3, 3),
('Mila', '43', 'Mila', 3, 3),
('Aïn Defla', '44', 'Aïn Defla', 3, 3),
('Naâma', '45', 'Naâma', 3, 3),
('Aïn Témouchent', '46', 'Aïn Témouchent', 3, 3),
('Ghardaïa', '47', 'Ghardaïa', 3, 3),
('Relizane', '48', 'Relizane', 3, 3),

-- Andorra Parishes (Country ID: 4, Timezone ID: 125 'Europe/Madrid')
('Canillo', '02', 'Canillo', 125, 4),
('Encamp', '03', 'Encamp', 125, 4),
('Ordino', '05', 'Ordino', 125, 4),
('La Massana', '04', 'La Massana', 125, 4),
('Andorra la Vella', '07', 'Andorra la Vella', 125, 4),
('Sant Julià de Lòria', '06', 'Sant Julià de Lòria', 125, 4),
('Escaldes-Engordany', '08', 'Escaldes-Engordany', 125, 4),

-- Angola Provinces (Country ID: 5, Timezone ID: 12 'Africa/Lagos')
('Bengo', 'BGO', 'Caxito', 12, 5),
('Benguela', 'BGU', 'Benguela', 12, 5),
('Bié', 'BIE', 'Cuíto', 12, 5),
('Cabinda', 'CAB', 'Cabinda', 12, 5),
('Cuando Cubango', 'CCU', 'Menongue', 12, 5),
('Cuanza Norte', 'CNO', 'N''dalatando', 12, 5),
('Cuanza Sul', 'CUS', 'Sumbe', 12, 5),
('Cunene', 'CNN', 'Ondjiva', 12, 5),
('Huambo', 'HUA', 'Huambo', 12, 5),
('Huíla', 'HUI', 'Lubango', 12, 5),
('Luanda', 'LUA', 'Luanda', 12, 5),
('Lunda Norte', 'LNO', 'Dundo', 12, 5),
('Lunda Sul', 'LSU', 'Saurimo', 12, 5),
('Malanje', 'MAL', 'Malanje', 12, 5),
('Moxico', 'MOX', 'Luena', 12, 5),
('Namibe', 'NAM', 'Moçâmedes', 12, 5),
('Uíge', 'UIG', 'Uíge', 12, 5),
('Zaire', 'ZAI', 'M''banza-Kongo', 12, 5),

-- Antigua and Barbuda Parishes (Country ID: 6, Timezone ID: 45 'America/Port_of_Spain')
('Saint George', '03', 'Piggots', 45, 6),
('Saint John', '04', 'Saint John''s', 45, 6),
('Saint Mary', '05', 'Bolans', 45, 6),
('Saint Paul', '06', 'Falmouth', 45, 6),
('Saint Peter', '07', 'Parham', 45, 6),
('Saint Philip', '08', 'Carlisle', 45, 6),
('Barbuda', '10', 'Codrington', 45, 6),
('Redonda', '11', 'Redonda', 45, 6),

-- Argentina Provinces (Country ID: 7, Timezone ID: 24 'America/Argentina/Buenos_Aires')
('Buenos Aires', 'B', 'La Plata', 24, 7),
('Catamarca', 'K', 'San Fernando del Valle de Catamarca', 24, 7),
('Chaco', 'H', 'Resistencia', 24, 7),
('Chubut', 'U', 'Rawson', 24, 7),
('Ciudad Autónoma de Buenos Aires', 'C', 'Buenos Aires', 24, 7),
('Córdoba', 'X', 'Córdoba', 24, 7),
('Corrientes', 'W', 'Corrientes', 24, 7),
('Entre Ríos', 'E', 'Paraná', 24, 7),
('Formosa', 'P', 'Formosa', 24, 7),
('Jujuy', 'Y', 'San Salvador de Jujuy', 24, 7),
('La Pampa', 'L', 'Santa Rosa', 24, 7),
('La Rioja', 'F', 'La Rioja', 24, 7),
('Mendoza', 'M', 'Mendoza', 24, 7),
('Misiones', 'N', 'Posadas', 24, 7),
('Neuquén', 'Q', 'Neuquén', 24, 7),
('Río Negro', 'R', 'Viedma', 24, 7),
('Salta', 'A', 'Salta', 24, 7),
('San Juan', 'J', 'San Juan', 24, 7),
('San Luis', 'D', 'San Luis', 24, 7),
('Santa Cruz', 'Z', 'Río Gallegos', 24, 7),
('Santa Fe', 'S', 'Santa Fe', 24, 7),
('Santiago del Estero', 'G', 'Santiago del Estero', 24, 7),
('Tierra del Fuego', 'V', 'Ushuaia', 24, 7),
('Tucumán', 'T', 'San Miguel de Tucumán', 24, 7),

-- Armenia Provinces (Country ID: 8, Timezone ID: 70 'Asia/Dubai')
('Aragatsotn', 'AG', 'Ashtarak', 70, 8),
('Ararat', 'AR', 'Artashat', 70, 8),
('Armavir', 'AV', 'Armavir', 70, 8),
('Gegharkunik', 'GR', 'Gavar', 70, 8),
('Kotayk', 'KT', 'Hrazdan', 70, 8),
('Lori', 'LO', 'Vanadzor', 70, 8),
('Shirak', 'SH', 'Gyumri', 70, 8),
('Syunik', 'SU', 'Kapan', 70, 8),
('Tavush', 'TV', 'Ijevan', 70, 8),
('Vayots Dzor', 'VD', 'Yeghegnadzor', 70, 8),
('Yerevan', 'ER', 'Yerevan', 70, 8),

-- Austria States (Country ID: 10, Timezone ID: 114 'Europe/Berlin')
('Burgenland', '1', 'Eisenstadt', 114, 10),
('Carinthia', '2', 'Klagenfurt', 114, 10),
('Lower Austria', '3', 'Sankt Pölten', 114, 10),
('Upper Austria', '4', 'Linz', 114, 10),
('Salzburg', '5', 'Salzburg', 114, 10),
('Styria', '6', 'Graz', 114, 10),
('Tyrol', '7', 'Innsbruck', 114, 10),
('Vorarlberg', '8', 'Bregenz', 114, 10),
('Vienna', '9', 'Vienna', 114, 10),

-- Azerbaijan Republics and Rayons (Country ID: 11, Timezone ID: 70 'Asia/Dubai')
('Absheron', 'ABS', 'Xirdalan', 70, 11),
('Agdam', 'AGM', 'Agdam', 70, 11),
('Agdash', 'AGS', 'Agdash', 70, 11),
('Aghjabadi', 'AGC', 'Aghjabadi', 70, 11),
('Agstafa', 'AGA', 'Agstafa', 70, 11),
('Agsu', 'AGU', 'Agsu', 70, 11),
('Astara', 'AST', 'Astara', 70, 11),
('Baku', 'BAK', 'Baku', 70, 11),
('Balakan', 'BAL', 'Balakan', 70, 11),
('Barda', 'BAR', 'Barda', 70, 11),
('Beylagan', 'BEY', 'Beylagan', 70, 11),
('Bilasuvar', 'BIL', 'Bilasuvar', 70, 11),
('Dashkasan', 'DAS', 'Dashkasan', 70, 11),
('Fuzuli', 'FUZ', 'Fuzuli', 70, 11),
('Gadabay', 'GAD', 'Gadabay', 70, 11),
('Ganja', 'GAN', 'Ganja', 70, 11),
('Gobustan', 'QOB', 'Gobustan', 70, 11),
('Goranboy', 'GOR', 'Goranboy', 70, 11),
('Goychay', 'GOY', 'Goychay', 70, 11),
('Goygol', 'GYG', 'Goygol', 70, 11),
('Hajigabul', 'HAC', 'Hajigabul', 70, 11),
('Imishli', 'IMI', 'Imishli', 70, 11),
('Ismailli', 'ISM', 'Ismailli', 70, 11),
('Jabrayil', 'JAB', 'Jabrayil', 70, 11),
('Jalilabad', 'CAL', 'Jalilabad', 70, 11),
('Kalbajar', 'KAL', 'Kalbajar', 70, 11),
('Khachmaz', 'XAC', 'Khachmaz', 70, 11),
('Khizi', 'XIZ', 'Khizi', 70, 11),
('Khojaly', 'XCI', 'Khojaly', 70, 11),
('Khojavend', 'XVD', 'Khojavend', 70, 11),
('Kurdamir', 'KUR', 'Kurdamir', 70, 11),
('Lachin', 'LAC', 'Lachin', 70, 11),
('Lankaran', 'LAN', 'Lankaran', 70, 11),
('Lerik', 'LER', 'Lerik', 70, 11),
('Masally', 'MAS', 'Masally', 70, 11),
('Mingachevir', 'MIN', 'Mingachevir', 70, 11),
('Nakhchivan', 'NX', 'Nakhchivan', 70, 11),
('Neftchala', 'NEF', 'Neftchala', 70, 11),
('Oghuz', 'OGU', 'Oghuz', 70, 11),
('Qabala', 'QAB', 'Qabala', 70, 11),
('Qakh', 'QAX', 'Qakh', 70, 11),
('Qazakh', 'QAZ', 'Qazakh', 70, 11),
('Quba', 'QBA', 'Quba', 70, 11),
('Qubadli', 'QBI', 'Qubadli', 70, 11),
('Qusar', 'QUS', 'Qusar', 70, 11),
('Saatly', 'SAT', 'Saatly', 70, 11),
('Sabirabad', 'SAB', 'Sabirabad', 70, 11),
('Salyan', 'SAL', 'Salyan', 70, 11),
('Samukh', 'SMX', 'Samukh', 70, 11),
('Shabran', 'SBN', 'Shabran', 70, 11),
('Shaki', 'SAK', 'Shaki', 70, 11),
('Shamakhi', 'SMI', 'Shamakhi', 70, 11),
('Shamkir', 'SKR', 'Shamkir', 70, 11),
('Shirvan', 'SR', 'Shirvan', 70, 11),
('Shusha', 'SUS', 'Shusha', 70, 11),
('Siazan', 'SIY', 'Siazan', 70, 11),
('Sumqayit', 'SM', 'Sumqayit', 70, 11),
('Tartar', 'TAR', 'Tartar', 70, 11),
('Tovuz', 'TOV', 'Tovuz', 70, 11),
('Ujar', 'UCA', 'Ujar', 70, 11),
('Yardymli', 'YAR', 'Yardymli', 70, 11),
('Yevlakh', 'YEV', 'Yevlakh', 70, 11),
('Zangilan', 'ZAN', 'Zangilan', 70, 11),
('Zaqatala', 'ZAQ', 'Zaqatala', 70, 11),
('Zardab', 'ZAR', 'Zardab', 70, 11),

-- Bahamas Districts (Country ID: 12, Timezone ID: 40 'America/New_York')
('Acklins', 'AK', 'Spring Point', 40, 12),
('Berry Islands', 'BY', 'Bullocks Harbour', 40, 12),
('Bimini', 'BI', 'Alice Town', 40, 12),
('Black Point', 'BP', 'Black Point', 40, 12),
('Cat Island', 'CI', 'Arthur''s Town', 40, 12),
('Central Abaco', 'CO', 'Marsh Harbour', 40, 12),
('Central Andros', 'CS', 'Fresh Creek', 40, 12),
('Central Eleuthera', 'CE', 'Governor''s Harbour', 40, 12),
('City of Freeport', 'FP', 'Freeport', 40, 12),
('Crooked Island and Long Cay', 'CK', 'Colonel Hill', 40, 12),
('East Grand Bahama', 'EG', 'High Rock', 40, 12),
('Exuma', 'EX', 'George Town', 40, 12),
('Grand Cay', 'GC', 'Grand Cay', 40, 12),
('Harbour Island', 'HI', 'Dunmore Town', 40, 12),
('Hope Town', 'HT', 'Hope Town', 40, 12),
('Inagua', 'IN', 'Matthew Town', 40, 12),
('Long Island', 'LI', 'Clarence Town', 40, 12),
('Mangrove Cay', 'MC', 'Moxey Town', 40, 12),
('Mayaguana', 'MG', 'Abraham''s Bay', 40, 12),
('Moore''s Island', 'MI', 'Hard Bargain', 40, 12),
('New Providence', 'NP', 'Nassau', 40, 12),
('North Abaco', 'NO', 'Cooper''s Town', 40, 12),
('North Andros', 'NS', 'Nicholls Town', 40, 12),
('North Eleuthera', 'NE', 'Upper Bogue', 40, 12),
('Ragged Island', 'RI', 'Duncan Town', 40, 12),
('Rum Cay', 'RC', 'Port Nelson', 40, 12),
('San Salvador', 'SS', 'Cockburn Town', 40, 12),
('South Abaco', 'SO', 'Sandy Point', 40, 12),
('South Andros', 'SA', 'Kemp''s Bay', 40, 12),
('South Eleuthera', 'SE', 'Rock Sound', 40, 12),
('Spanish Wells', 'SW', 'Spanish Wells', 40, 12),
('West Grand Bahama', 'WG', 'Eight Mile Rock', 40, 12),

-- Bahrain Governorates (Country ID: 13, Timezone ID: 86 'Asia/Qatar')
('Capital Governorate', '13', 'Manama', 86, 13),
('Southern Governorate', '14', 'Riffa', 86, 13),
('Muharraq Governorate', '15', 'Muharraq', 86, 13),
('Northern Governorate', '17', 'Sar', 86, 13),

-- Bangladesh Divisions (Country ID: 14, Timezone ID: 60 'Asia/Almaty')
('Barisal', 'A', 'Barisal', 60, 14),
('Chittagong', 'B', 'Chittagong', 60, 14),
('Dhaka', 'C', 'Dhaka', 60, 14),
('Khulna', 'D', 'Khulna', 60, 14),
('Mymensingh', 'H', 'Mymensingh', 60, 14),
('Rajshahi', 'E', 'Rajshahi', 60, 14),
('Rangpur', 'F', 'Rangpur', 60, 14),
('Sylhet', 'G', 'Sylhet', 60, 14),

-- Barbados Parishes (Country ID: 15, Timezone ID: 45 'America/Port_of_Spain')
('Christ Church', '01', 'Oistins', 45, 15),
('Saint Andrew', '02', 'Greenland', 45, 15),
('Saint George', '03', 'The Glebe', 45, 15),
('Saint James', '04', 'Holetown', 45, 15),
('Saint John', '05', 'Four Roads', 45, 15),
('Saint Joseph', '06', 'Bathsheba', 45, 15),
('Saint Lucy', '07', 'Crab Hill', 45, 15),
('Saint Michael', '08', 'Bridgetown', 45, 15),
('Saint Peter', '09', 'Speightstown', 45, 15),
('Saint Philip', '10', 'Crane', 45, 15),
('Saint Thomas', '11', 'Hillaby', 45, 15),

-- Belarus Regions (Country ID: 16, Timezone ID: 126 'Europe/Moscow')
('Brest Region', 'BR', 'Brest', 126, 16),
('Gomel Region', 'HO', 'Gomel', 126, 16),
('Grodno Region', 'HR', 'Grodno', 126, 16),
('Minsk Region', 'MI', 'Minsk', 126, 16),
('Mogilev Region', 'MA', 'Mogilev', 126, 16),
('Vitebsk Region', 'VI', 'Vitebsk', 126, 16),
('Minsk City', 'HM', 'Minsk', 126, 16),

-- Belgium Regions (Country ID: 17, Timezone ID: 115 'Europe/Brussels')
('Brussels-Capital Region', 'BRU', 'Brussels', 115, 17),
('Flemish Region', 'VLG', 'Brussels', 115, 17),
('Walloon Region', 'WAL', 'Namur', 115, 17),

-- Belize Districts (Country ID: 18, Timezone ID: 31 'America/Costa_Rica')
('Belize', 'BZ', 'Belize City', 31, 18),
('Cayo', 'CY', 'San Ignacio', 31, 18),
('Corozal', 'CZL', 'Corozal Town', 31, 18),
('Orange Walk', 'OW', 'Orange Walk Town', 31, 18),
('Stann Creek', 'SC', 'Dangriga', 31, 18),
('Toledo', 'TOL', 'Punta Gorda', 31, 18),

-- Benin Departments (Country ID: 19, Timezone ID: 12 'Africa/Lagos')
('Alibori', 'AL', 'Kandi', 12, 19),
('Atakora', 'AK', 'Natitingou', 12, 19),
('Atlantique', 'AQ', 'Allada', 12, 19),
('Borgou', 'BO', 'Parakou', 12, 19),
('Collines', 'CO', 'Dassa-Zoumé', 12, 19),
('Donga', 'DO', 'Djougou', 12, 19),
('Kouffo', 'KO', 'Aplahoué', 12, 19),
('Littoral', 'LI', 'Cotonou', 12, 19),
('Mono', 'MO', 'Lokossa', 12, 19),
('Ouémé', 'OU', 'Porto-Novo', 12, 19),
('Plateau', 'PL', 'Pobè', 12, 19),
('Zou', 'ZO', 'Abomey', 12, 19),

-- Bhutan Districts (Country ID: 20, Timezone ID: 60 'Asia/Almaty')
('Bumthang', '33', 'Jakar', 60, 20),
('Chukha', '12', 'Phuntsholing', 60, 20),
('Dagana', '22', 'Dagana', 60, 20),
('Gasa', 'GA', 'Gasa', 60, 20),
('Haa', '13', 'Haa', 60, 20),
('Lhuntse', '44', 'Lhuntse', 60, 20),
('Mongar', '42', 'Mongar', 60, 20),
('Paro', '11', 'Paro', 60, 20),
('Pemagatshel', '43', 'Pemagatshel', 60, 20),
('Punakha', '23', 'Punakha', 60, 20),
('Samdrup Jongkhar', '45', 'Samdrup Jongkhar', 60, 20),
('Samtse', '14', 'Samtse', 60, 20),
('Sarpang', '31', 'Sarpang', 60, 20),
('Thimphu', '15', 'Thimphu', 60, 20),
('Trashigang', '41', 'Trashigang', 60, 20),
('Trashiyangtse', 'TY', 'Trashiyangtse', 60, 20),
('Trongsa', '32', 'Trongsa', 60, 20),
('Tsirang', '21', 'Tsirang', 60, 20),
('Wangdue Phodrang', '24', 'Wangdue Phodrang', 60, 20),
('Zhemgang', '34', 'Zhemgang', 60, 20),

-- Bolivia Departments (Country ID: 21, Timezone ID: 29 'America/Caracas')
('Beni', 'B', 'Trinidad', 29, 21),
('Chuquisaca', 'H', 'Sucre', 29, 21),
('Cochabamba', 'C', 'Cochabamba', 29, 21),
('La Paz', 'L', 'La Paz', 29, 21),
('Oruro', 'O', 'Oruro', 29, 21),
('Pando', 'N', 'Cobija', 29, 21),
('Potosí', 'P', 'Potosí', 29, 21),
('Santa Cruz', 'S', 'Santa Cruz de la Sierra', 29, 21),
('Tarija', 'T', 'Tarija', 29, 21),

-- Bosnia and Herzegovina Entities (Country ID: 22, Timezone ID: 114 'Europe/Berlin')
('Federation of Bosnia and Herzegovina', 'BIH', 'Sarajevo', 114, 22),
('Republika Srpska', 'SRP', 'Banja Luka', 114, 22),
('Brčko District', 'BRC', 'Brčko', 114, 22),

-- Botswana Districts (Country ID: 23, Timezone ID: 9 'Africa/Johannesburg')
('Central', 'CE', 'Serowe', 9, 23),
('Ghanzi', 'GH', 'Ghanzi', 9, 23),
('Kgalagadi', 'KG', 'Tsabong', 9, 23),
('Kgatleng', 'KL', 'Mochudi', 9, 23),
('Kweneng', 'KW', 'Molepolole', 9, 23),
('North-East', 'NE', 'Masunga', 9, 23),
('North-West', 'NW', 'Maun', 9, 23),
('South-East', 'SE', 'Ramotswa', 9, 23),
('Southern', 'SO', 'Kanye', 9, 23),

-- Brunei Darussalam Districts (Country ID: 25, Timezone ID: 68 'Asia/Brunei')
('Belait', 'BE', 'Kuala Belait', 68, 25),
('Brunei-Muara', 'BM', 'Bandar Seri Begawan', 68, 25),
('Temburong', 'TE', 'Bangar', 68, 25),
('Tutong', 'TU', 'Tutong', 68, 25),

-- Bulgaria Provinces (Country ID: 26, Timezone ID: 130 'Europe/Sofia')
('Blagoevgrad', '01', 'Blagoevgrad', 130, 26),
('Burgas', '02', 'Burgas', 130, 26),
('Varna', '03', 'Varna', 130, 26),
('Veliko Tarnovo', '04', 'Veliko Tarnovo', 130, 26),
('Vidin', '05', 'Vidin', 130, 26),
('Vratsa', '06', 'Vratsa', 130, 26),
('Gabrovo', '07', 'Gabrovo', 130, 26),
('Dobrich', '08', 'Dobrich', 130, 26),
('Kardzhali', '09', 'Kardzhali', 130, 26),
('Kyustendil', '10', 'Kyustendil', 130, 26),
('Lovech', '11', 'Lovech', 130, 26),
('Montana', '12', 'Montana', 130, 26),
('Pazardzhik', '13', 'Pazardzhik', 130, 26),
('Pernik', '14', 'Pernik', 130, 26),
('Pleven', '15', 'Pleven', 130, 26),
('Plovdiv', '16', 'Plovdiv', 130, 26),
('Razgrad', '17', 'Razgrad', 130, 26),
('Ruse', '18', 'Ruse', 130, 26),
('Silistra', '19', 'Silistra', 130, 26),
('Sliven', '20', 'Sliven', 130, 26),
('Smolyan', '21', 'Smolyan', 130, 26),
('Sofia City', '22', 'Sofia', 130, 26),
('Sofia Province', '23', 'Sofia', 130, 26),
('Stara Zagora', '24', 'Stara Zagora', 130, 26),
('Targovishte', '25', 'Targovishte', 130, 26),
('Haskovo', '26', 'Haskovo', 130, 26),
('Shumen', '27', 'Shumen', 130, 26),
('Yambol', '28', 'Yambol', 130, 26),

-- Burkina Faso Regions (Country ID: 27, Timezone ID: 1 'Africa/Abidjan')
('Boucle du Mouhoun', '01', 'Dédougou', 1, 27),
('Cascades', '02', 'Banfora', 1, 27),
('Centre', '03', 'Ouagadougou', 1, 27),
('Centre-Est', '04', 'Tenkodogo', 1, 27),
('Centre-Nord', '05', 'Kaya', 1, 27),
('Centre-Ouest', '06', 'Koudougou', 1, 27),
('Centre-Sud', '07', 'Manga', 1, 27),
('Est', '08', 'Fada N''gourma', 1, 27),
('Hauts-Bassins', '09', 'Bobo-Dioulasso', 1, 27),
('Nord', '10', 'Ouahigouya', 1, 27),
('Plateau-Central', '11', 'Ziniaré', 1, 27),
('Sahel', '12', 'Dori', 1, 27),
('Sud-Ouest', '13', 'Gaoua', 1, 27),

-- Burundi Provinces (Country ID: 28, Timezone ID: 9 'Africa/Johannesburg')
('Bubanza', 'BB', 'Bubanza', 9, 28),
('Bujumbura Mairie', 'BM', 'Bujumbura', 9, 28),
('Bujumbura Rural', 'BL', 'Isale', 9, 28),
('Bururi', 'BR', 'Bururi', 9, 28),
('Cankuzo', 'CA', 'Cankuzo', 9, 28),
('Cibitoke', 'CI', 'Cibitoke', 9, 28),
('Gitega', 'GI', 'Gitega', 9, 28),
('Karuzi', 'KR', 'Karuzi', 9, 28),
('Kayanza', 'KY', 'Kayanza', 9, 28),
('Kirundo', 'KI', 'Kirundo', 9, 28),
('Makamba', 'MA', 'Makamba', 9, 28),
('Muramvya', 'MU', 'Muramvya', 9, 28),
('Muyinga', 'MY', 'Muyinga', 9, 28),
('Mwaro', 'MW', 'Mwaro', 9, 28),
('Ngozi', 'NG', 'Ngozi', 9, 28),
('Rumonge', 'RM', 'Rumonge', 9, 28),
('Rutana', 'RT', 'Rutana', 9, 28),
('Ruyigi', 'RY', 'Ruyigi', 9, 28),

-- Cambodia Provinces (Country ID: 29, Timezone ID: 66 'Asia/Bangkok')
('Banteay Meanchey', '1', 'Serei Saophoan', 66, 29),
('Battambang', '2', 'Battambang', 66, 29),
('Kampong Cham', '3', 'Kampong Cham', 66, 29),
('Kampong Chhnang', '4', 'Kampong Chhnang', 66, 29),
('Kampong Speu', '5', 'Chbar Mon', 66, 29),
('Kampong Thom', '6', 'Stung Saen', 66, 29),
('Kampot', '7', 'Kampot', 66, 29),
('Kandal', '8', 'Ta Khmau', 66, 29),
('Koh Kong', '9', 'Khemarak Phoumin', 66, 29),
('Kratié', '10', 'Kratié', 66, 29),
('Mondulkiri', '11', 'Senmonorom', 66, 29),
('Phnom Penh', '12', 'Phnom Penh', 66, 29),
('Preah Vihear', '13', 'Tbaeng Meanchey', 66, 29),
('Prey Veng', '14', 'Prey Veng', 66, 29),
('Pursat', '15', 'Pursat', 66, 29),
('Ratanakiri', '16', 'Banlung', 66, 29),
('Siem Reap', '17', 'Siem Reap', 66, 29),
('Preah Sihanouk', '18', 'Sihanoukville', 66, 29),
('Stung Treng', '19', 'Stung Treng', 66, 29),
('Svay Rieng', '20', 'Svay Rieng', 66, 29),
('Takéo', '21', 'Doun Kaev', 66, 29),
('Oddar Meanchey', '22', 'Samraong', 66, 29),
('Kep', '23', 'Kep', 66, 29),
('Pailin', '24', 'Pailin', 66, 29),
('Tboung Khmum', '25', 'Suong', 66, 29),

-- Cameroon Regions (Country ID: 30, Timezone ID: 12 'Africa/Lagos')
('Adamawa', 'AD', 'Ngaoundéré', 12, 30),
('Centre', 'CE', 'Yaoundé', 12, 30),
('East', 'ES', 'Bertoua', 12, 30),
('Far North', 'EN', 'Maroua', 12, 30),
('Littoral', 'LT', 'Douala', 12, 30),
('North', 'NO', 'Garoua', 12, 30),
('North-West', 'NW', 'Bamenda', 12, 30),
('South', 'SU', 'Ebolowa', 12, 30),
('South-West', 'SW', 'Buea', 12, 30),
('West', 'OU', 'Bafoussam', 12, 30),

-- Cape Verde Municipalities (Country ID: 32, Timezone ID: 99 'Atlantic/Cape_Verde')
('Boa Vista', 'BV', 'Sal Rei', 99, 32),
('Brava', 'BR', 'Nova Sintra', 99, 32),
('Maio', 'MA', 'Vila do Maio', 99, 32),
('Mosteiros', 'MO', 'Mosteiros', 99, 32),
('Paul', 'PA', 'Pombas', 99, 32),
('Porto Novo', 'PN', 'Porto Novo', 99, 32),
('Praia', 'PR', 'Praia', 99, 32),
('Ribeira Brava', 'RB', 'Ribeira Brava', 99, 32),
('Ribeira Grande', 'RG', 'Ribeira Grande', 99, 32),
('Ribeira Grande de Santiago', 'RS', 'Cidade Velha', 99, 32),
('Sal', 'SL', 'Espargos', 99, 32),
('Santa Catarina', 'CA', 'Assomada', 99, 32),
('Santa Catarina do Fogo', 'CF', 'Cova Figueira', 99, 32),
('Santa Cruz', 'CR', 'Pedra Badejo', 99, 32),
('São Domingos', 'SD', 'São Domingos', 99, 32),
('São Filipe', 'SF', 'São Filipe', 99, 32),
('São Lourenço dos Órgãos', 'SO', 'João Teves', 99, 32),
('São Miguel', 'SM', 'Calheta de São Miguel', 99, 32),
('São Salvador do Mundo', 'SS', 'Picos', 99, 32),
('São Vicente', 'SV', 'Mindelo', 99, 32),
('Tarrafal', 'TA', 'Tarrafal', 99, 32),
('Tarrafal de São Nicolau', 'TS', 'Tarrafal de São Nicolau', 99, 32),

-- Central African Republic Prefectures (Country ID: 33, Timezone ID: 12 'Africa/Lagos')
('Bamingui-Bangoran', 'BB', 'Ndélé', 12, 33),
('Bangui', 'BGF', 'Bangui', 12, 33),
('Basse-Kotto', 'BK', 'Mobaye', 12, 33),
('Haute-Kotto', 'HK', 'Bria', 12, 33),
('Haut-Mbomou', 'HM', 'Obo', 12, 33),
('Kémo', 'KG', 'Sibut', 12, 33),
('Lobaye', 'LB', 'Mbaïki', 12, 33),
('Mambéré-Kadéï', 'HS', 'Berbérati', 12, 33),
('Mbomou', 'MB', 'Bangassou', 12, 33),
('Nana-Grébizi', 'KB', 'Kaga-Bandoro', 12, 33),
('Nana-Mambéré', 'NM', 'Bouar', 12, 33),
('Ombella-M''Poko', 'MP', 'Bimbo', 12, 33),
('Ouaka', 'UK', 'Bambari', 12, 33),
('Ouham', 'AC', 'Bossangoa', 12, 33),
('Ouham-Pendé', 'OP', 'Bozoum', 12, 33),
('Sangha-Mbaéré', 'SE', 'Nola', 12, 33),
('Vakaga', 'VK', 'Birao', 12, 33),

-- Chad Regions (Country ID: 34, Timezone ID: 16 'Africa/Ndjamena')
('Batha', 'BA', 'Ati', 16, 34),
('Chari-Baguirmi', 'CB', 'Massenya', 16, 34),
('Hadjer-Lamis', 'HL', 'Massakory', 16, 34),
('Wadi Fira', 'WF', 'Biltine', 16, 34),
('Bahr el Gazel', 'BG', 'Moussoro', 16, 34),
('Borkou', 'BO', 'Faya-Largeau', 16, 34),
('Ennedi-Est', 'EE', 'Am-Djarass', 16, 34),
('Ennedi-Ouest', 'EO', 'Fada', 16, 34),
('Guéra', 'GR', 'Mongo', 16, 34),
('Kanem', 'KA', 'Mao', 16, 34),
('Lac', 'LC', 'Bol', 16, 34),
('Logone Occidental', 'LO', 'Moundou', 16, 34),
('Logone Oriental', 'LR', 'Doba', 16, 34),
('Mandoul', 'MA', 'Koumra', 16, 34),
('Mayo-Kebbi Est', 'ME', 'Bongor', 16, 34),
('Mayo-Kebbi Ouest', 'MO', 'Pala', 16, 34),
('Moyen-Chari', 'MC', 'Sarh', 16, 34),
('Ouaddaï', 'OD', 'Abéché', 16, 34),
('Salamat', 'SA', 'Am Timan', 16, 34),
('Sila', 'SI', 'Goz Beïda', 16, 34),
('Tandjilé', 'TA', 'Laï', 16, 34),
('Tibesti', 'TI', 'Bardaï', 16, 34),
('N''Djamena', 'ND', 'N''Djamena', 16, 34),

-- Chile Regions (Country ID: 35, Timezone ID: 46 'America/Santiago')
('Aisén', 'AI', 'Coihaique', 46, 35),
('Antofagasta', 'AN', 'Antofagasta', 46, 35),
('Arica y Parinacota', 'AP', 'Arica', 46, 35),
('Atacama', 'AT', 'Copiapó', 46, 35),
('Biobío', 'BI', 'Concepción', 46, 35),
('Coquimbo', 'CO', 'La Serena', 46, 35),
('La Araucanía', 'AR', 'Temuco', 46, 35),
('Libertador General Bernardo O''Higgins', 'LI', 'Rancagua', 46, 35),
('Los Lagos', 'LL', 'Puerto Montt', 46, 35),
('Los Ríos', 'LR', 'Valdivia', 46, 35),
('Magallanes', 'MA', 'Punta Arenas', 46, 35),
('Maule', 'ML', 'Talca', 46, 35),
('Ñuble', 'NB', 'Chillán', 46, 35),
('Región Metropolitana de Santiago', 'RM', 'Santiago', 46, 35),
('Tarapacá', 'TA', 'Iquique', 46, 35),
('Valparaíso', 'VS', 'Valparaíso', 46, 35),

-- Colombia Departments (Country ID: 37, Timezone ID: 28 'America/Bogota')
('Amazonas', 'AMA', 'Leticia', 28, 37),
('Antioquia', 'ANT', 'Medellín', 28, 37),
('Arauca', 'ARA', 'Arauca', 28, 37),
('Atlántico', 'ATL', 'Barranquilla', 28, 37),
('Bogotá', 'DC', 'Bogotá', 28, 37),
('Bolívar', 'BOL', 'Cartagena', 28, 37),
('Boyacá', 'BOY', 'Tunja', 28, 37),
('Caldas', 'CAL', 'Manizales', 28, 37),
('Caquetá', 'CAQ', 'Florencia', 28, 37),
('Casanare', 'CAS', 'Yopal', 28, 37),
('Cauca', 'CAU', 'Popayán', 28, 37),
('Cesar', 'CES', 'Valledupar', 28, 37),
('Chocó', 'CHO', 'Quibdó', 28, 37),
('Córdoba', 'COR', 'Montería', 28, 37),
('Cundinamarca', 'CUN', 'Bogotá', 28, 37),
('Guainía', 'GUA', 'Inírida', 28, 37),
('Guaviare', 'GUV', 'San José del Guaviare', 28, 37),
('Huila', 'HUI', 'Neiva', 28, 37),
('La Guajira', 'LAG', 'Riohacha', 28, 37),
('Magdalena', 'MAG', 'Santa Marta', 28, 37),
('Meta', 'MET', 'Villavicencio', 28, 37),
('Nariño', 'NAR', 'Pasto', 28, 37),
('Norte de Santander', 'NSA', 'Cúcuta', 28, 37),
('Putumayo', 'PUT', 'Mocoa', 28, 37),
('Quindío', 'QUI', 'Armenia', 28, 37),
('Risaralda', 'RIS', 'Pereira', 28, 37),
('San Andrés y Providencia', 'SAP', 'San Andrés', 28, 37),
('Santander', 'SAN', 'Bucaramanga', 28, 37),
('Sucre', 'SUC', 'Sincelejo', 28, 37),
('Tolima', 'TOL', 'Ibagué', 28, 37),
('Valle del Cauca', 'VAC', 'Cali', 28, 37),
('Vaupés', 'VAU', 'Mitú', 28, 37),
('Vichada', 'VID', 'Puerto Carreño', 28, 37),

-- Comoros Islands (Country ID: 38, Timezone ID: 15 'Africa/Nairobi')
('Anjouan', 'A', 'Mutsamudu', 15, 38),
('Grande Comore', 'G', 'Moroni', 15, 38),
('Mohéli', 'M', 'Fomboni', 15, 38),

-- Congo Departments (Country ID: 39, Timezone ID: 12 'Africa/Lagos')
('Bouenza', '11', 'Madingou', 12, 39),
('Brazzaville', 'BZV', 'Brazzaville', 12, 39),
('Cuvette', '8', 'Owando', 12, 39),
('Cuvette-Ouest', '15', 'Ewo', 12, 39),
('Kouilou', '5', 'Hinda', 12, 39),
('Lékoumou', '2', 'Sibiti', 12, 39),
('Likouala', '7', 'Impfondo', 12, 39),
('Niari', '9', 'Dolisie', 12, 39),
('Plateaux', '14', 'Djambala', 12, 39),
('Pointe-Noire', '16', 'Pointe-Noire', 12, 39),
('Pool', '12', 'Kinkala', 12, 39),
('Sangha', '13', 'Ouésso', 12, 39),

-- Costa Rica Provinces (Country ID: 40, Timezone ID: 31 'America/Costa_Rica')
('Alajuela', 'A', 'Alajuela', 31, 40),
('Cartago', 'C', 'Cartago', 31, 40),
('Guanacaste', 'G', 'Liberia', 31, 40),
('Heredia', 'H', 'Heredia', 31, 40),
('Limón', 'L', 'Puerto Limón', 31, 40),
('Puntarenas', 'P', 'Puntarenas', 31, 40),
('San José', 'SJ', 'San José', 31, 40),

-- Côte d'Ivoire Districts (Country ID: 41, Timezone ID: 1 'Africa/Abidjan')
('Abidjan', 'AB', 'Abidjan', 1, 41),
('Bas-Sassandra', 'BS', 'San-Pédro', 1, 41),
('Comoé', 'CM', 'Abengourou', 1, 41),
('Denguélé', 'DN', 'Odienné', 1, 41),
('Gôh-Djiboua', 'GD', 'Gagnoa', 1, 41),
('Lacs', 'LC', 'Dimbokro', 1, 41),
('Lagunes', 'LG', 'Dabou', 1, 41),
('Montagnes', 'MG', 'Man', 1, 41),
('Sassandra-Marahoué', 'SM', 'Daloa', 1, 41),
('Savanes', 'SV', 'Korhogo', 1, 41),
('Vallée du Bandama', 'VB', 'Bouaké', 1, 41),
('Woroba', 'WR', 'Séguéla', 1, 41),
('Yamoussoukro', 'YM', 'Yamoussoukro', 1, 41),
('Zanzan', 'ZZ', 'Bondoukou', 1, 41),

-- Croatia Counties (Country ID: 42, Timezone ID: 114 'Europe/Berlin')
('Bjelovar-Bilogora', '07', 'Bjelovar', 114, 42),
('Brod-Posavina', '12', 'Slavonski Brod', 114, 42),
('Dubrovnik-Neretva', '19', 'Dubrovnik', 114, 42),
('Istria', '18', 'Pazin', 114, 42),
('Karlovac', '04', 'Karlovac', 114, 42),
('Koprivnica-Križevci', '06', 'Koprivnica', 114, 42),
('Krapina-Zagorje', '02', 'Krapina', 114, 42),
('Lika-Senj', '09', 'Gospić', 114, 42),
('Međimurje', '20', 'Čakovec', 114, 42),
('Osijek-Baranja', '14', 'Osijek', 114, 42),
('Požega-Slavonia', '11', 'Požega', 114, 42),
('Primorje-Gorski Kotar', '08', 'Rijeka', 114, 42),
('Šibenik-Knin', '15', 'Šibenik', 114, 42),
('Sisak-Moslavina', '03', 'Sisak', 114, 42),
('Split-Dalmatia', '17', 'Split', 114, 42),
('Varaždin', '05', 'Varaždin', 114, 42),
('Virovitica-Podravina', '10', 'Virovitica', 114, 42),
('Vukovar-Syrmia', '16', 'Vukovar', 114, 42),
('Zadar', '13', 'Zadar', 114, 42),
('Zagreb County', '01', 'Zagreb', 114, 42),
('City of Zagreb', '21', 'Zagreb', 114, 42),

-- Cuba Provinces (Country ID: 43, Timezone ID: 44 'America/Port-au-Prince')
('Artemisa', '15', 'Artemisa', 44, 43),
('Camagüey', '09', 'Camagüey', 44, 43),
('Ciego de Ávila', '08', 'Ciego de Ávila', 44, 43),
('Cienfuegos', '06', 'Cienfuegos', 44, 43),
('Granma', '12', 'Bayamo', 44, 43),
('Guantánamo', '14', 'Guantánamo', 44, 43),
('Holguín', '11', 'Holguín', 44, 43),
('Isla de la Juventud', '99', 'Nueva Gerona', 44, 43),
('La Habana', '03', 'Havana', 44, 43),
('Las Tunas', '10', 'Victoria de Las Tunas', 44, 43),
('Matanzas', '04', 'Matanzas', 44, 43),
('Mayabeque', '16', 'San José de las Lajas', 44, 43),
('Pinar del Río', '01', 'Pinar del Río', 44, 43),
('Sancti Spíritus', '07', 'Sancti Spíritus', 44, 43),
('Santiago de Cuba', '13', 'Santiago de Cuba', 44, 43),
('Villa Clara', '05', 'Santa Clara', 44, 43),

-- Cyprus Districts (Country ID: 44, Timezone ID: 85 'Asia/Nicosia')
('Famagusta', '04', 'Famagusta', 85, 44),
('Kyrenia', '06', 'Kyrenia', 85, 44),
('Larnaca', '03', 'Larnaca', 85, 44),
('Limassol', '02', 'Limassol', 85, 44),
('Nicosia', '01', 'Nicosia', 85, 44),
('Paphos', '05', 'Paphos', 85, 44),

-- Czech Republic Regions (Country ID: 45, Timezone ID: 128 'Europe/Prague')
('Prague', '10', 'Prague', 128, 45),
('Central Bohemian', '20', 'Prague', 128, 45),
('South Bohemian', '31', 'České Budějovice', 128, 45),
('Plzeň', '32', 'Plzeň', 128, 45),
('Karlovy Vary', '41', 'Karlovy Vary', 128, 45),
('Ústí nad Labem', '42', 'Ústí nad Labem', 128, 45),
('Liberec', '51', 'Liberec', 128, 45),
('Hradec Králové', '52', 'Hradec Králové', 128, 45),
('Pardubice', '53', 'Pardubice', 128, 45),
('Vysočina', '63', 'Jihlava', 128, 45),
('South Moravian', '64', 'Brno', 128, 45),
('Olomouc', '71', 'Olomouc', 128, 45),
('Moravian-Silesian', '80', 'Ostrava', 128, 45),
('Zlín', '72', 'Zlín', 128, 45),

-- Denmark Regions (Country ID: 46, Timezone ID: 118 'Europe/Copenhagen')
('Capital Region of Denmark', '84', 'Hillerød', 118, 46),
('Central Denmark Region', '82', 'Viborg', 118, 46),
('North Denmark Region', '81', 'Aalborg', 118, 46),
('Region of Southern Denmark', '83', 'Vejle', 118, 46),
('Region Zealand', '85', 'Sorø', 118, 46),

-- Djibouti Regions (Country ID: 47, Timezone ID: 15 'Africa/Nairobi')
('Ali Sabieh', 'AS', 'Ali Sabieh', 15, 47),
('Arta', 'AR', 'Arta', 15, 47),
('Dikhil', 'DI', 'Dikhil', 15, 47),
('Djibouti', 'DJ', 'Djibouti', 15, 47),
('Obock', 'OB', 'Obock', 15, 47),
('Tadjourah', 'TA', 'Tadjourah', 15, 47),

-- Dominica Parishes (Country ID: 48, Timezone ID: 45 'America/Port_of_Spain')
('Saint Andrew', '02', 'Marigot', 45, 48),
('Saint David', '03', 'Rosalie', 45, 48),
('Saint George', '04', 'Roseau', 45, 48),
('Saint John', '05', 'Portsmouth', 45, 48),
('Saint Joseph', '06', 'Saint Joseph', 45, 48),
('Saint Luke', '07', 'Pointe Michel', 45, 48),
('Saint Mark', '08', 'Soufrière', 45, 48),
('Saint Patrick', '09', 'Grand Bay', 45, 48),
('Saint Paul', '10', 'Mahaut', 45, 48),
('Saint Peter', '11', 'Colihaut', 45, 48),

-- Dominican Republic Provinces (Country ID: 49, Timezone ID: 40 'America/New_York')
('Azua', '02', 'Azua de Compostela', 40, 49),
('Baoruco', '03', 'Neiba', 40, 49),
('Barahona', '04', 'Santa Cruz de Barahona', 40, 49),
('Dajabón', '05', 'Dajabón', 40, 49),
('Distrito Nacional', '01', 'Santo Domingo', 40, 49),
('Duarte', '06', 'San Francisco de Macorís', 40, 49),
('El Seibo', '08', 'Santa Cruz de El Seibo', 40, 49),
('Elías Piña', '07', 'Comendador', 40, 49),
('Espaillat', '09', 'Moca', 40, 49),
('Hato Mayor', '30', 'Hato Mayor del Rey', 40, 49),
('Hermanas Mirabal', '19', 'Salcedo', 40, 49),
('Independencia', '10', 'Jimaní', 40, 49),
('La Altagracia', '11', 'Salvaleón de Higüey', 40, 49),
('La Romana', '12', 'La Romana', 40, 49),
('La Vega', '13', 'Concepción de La Vega', 40, 49),
('María Trinidad Sánchez', '14', 'Nagua', 40, 49),
('Monseñor Nouel', '28', 'Bonao', 40, 49),
('Monte Cristi', '15', 'San Fernando de Monte Cristi', 40, 49),
('Monte Plata', '29', 'Monte Plata', 40, 49),
('Pedernales', '16', 'Pedernales', 40, 49),
('Peravia', '17', 'Baní', 40, 49),
('Puerto Plata', '18', 'San Felipe de Puerto Plata', 40, 49),
('Samaná', '20', 'Samaná', 40, 49),
('San Cristóbal', '21', 'San Cristóbal', 40, 49),
('San José de Ocoa', '31', 'San José de Ocoa', 40, 49),
('San Juan', '22', 'San Juan de la Maguana', 40, 49),
('San Pedro de Macorís', '23', 'San Pedro de Macorís', 40, 49),
('Sánchez Ramírez', '24', 'Cotuí', 40, 49),
('Santiago', '25', 'Santiago de los Caballeros', 40, 49),
('Santiago Rodríguez', '26', 'Sabaneta', 40, 49),
('Santo Domingo', '32', 'Santo Domingo Este', 40, 49),
('Valverde', '27', 'Mao', 40, 49),

-- Ecuador Provinces (Country ID: 50, Timezone ID: 28 'America/Bogota')
('Azuay', 'A', 'Cuenca', 28, 50),
('Bolívar', 'B', 'Guaranda', 28, 50),
('Cañar', 'F', 'Azogues', 28, 50),
('Carchi', 'C', 'Tulcán', 28, 50),
('Chimborazo', 'H', 'Riobamba', 28, 50),
('Cotopaxi', 'X', 'Latacunga', 28, 50),
('El Oro', 'O', 'Machala', 28, 50),
('Esmeraldas', 'E', 'Esmeraldas', 28, 50),
('Galápagos', 'W', 'Puerto Baquerizo Moreno', 28, 50),
('Guayas', 'G', 'Guayaquil', 28, 50),
('Imbabura', 'I', 'Ibarra', 28, 50),
('Loja', 'L', 'Loja', 28, 50),
('Los Ríos', 'R', 'Babahoyo', 28, 50),
('Manabí', 'M', 'Portoviejo', 28, 50),
('Morona-Santiago', 'S', 'Macas', 28, 50),
('Napo', 'N', 'Tena', 28, 50),
('Orellana', 'D', 'Puerto Francisco de Orellana', 28, 50),
('Pastaza', 'Y', 'Puyo', 28, 50),
('Pichincha', 'P', 'Quito', 28, 50),
('Santa Elena', 'SE', 'Santa Elena', 28, 50),
('Santo Domingo de los Tsáchilas', 'SD', 'Santo Domingo', 28, 50),
('Sucumbíos', 'U', 'Nueva Loja', 28, 50),
('Tungurahua', 'T', 'Ambato', 28, 50),
('Zamora-Chinchipe', 'Z', 'Zamora', 28, 50),

-- Egypt Governorates (Country ID: 51, Timezone ID: 5 'Africa/Cairo')
('Alexandria', 'ALX', 'Alexandria', 5, 51),
('Aswan', 'ASN', 'Aswan', 5, 51),
('Asyut', 'AST', 'Asyut', 5, 51),
('Beheira', 'BH', 'Damanhur', 5, 51),
('Beni Suef', 'BNS', 'Beni Suef', 5, 51),
('Cairo', 'C', 'Cairo', 5, 51),
('Dakahlia', 'DK', 'Mansoura', 5, 51),
('Damietta', 'DT', 'Damietta', 5, 51),
('Faiyum', 'FYM', 'Faiyum', 5, 51),
('Gharbia', 'GH', 'Tanta', 5, 51),
('Giza', 'GZ', 'Giza', 5, 51),
('Ismailia', 'IS', 'Ismailia', 5, 51),
('Kafr el-Sheikh', 'KFS', 'Kafr el-Sheikh', 5, 51),
('Luxor', 'LX', 'Luxor', 5, 51),
('Matrouh', 'MT', 'Mersa Matruh', 5, 51),
('Minya', 'MN', 'Minya', 5, 51),
('Monufia', 'MNF', 'Shibin El Kom', 5, 51),
('New Valley', 'WAD', 'Kharga', 5, 51),
('North Sinai', 'SIN', 'Arish', 5, 51),
('Port Said', 'PTS', 'Port Said', 5, 51),
('Qalyubia', 'KB', 'Banha', 5, 51),
('Qena', 'KN', 'Qena', 5, 51),
('Red Sea', 'BA', 'Hurghada', 5, 51),
('Sharqia', 'SHR', 'Zagazig', 5, 51),
('Sohag', 'SHG', 'Sohag', 5, 51),
('South Sinai', 'JS', 'El Tor', 5, 51),
('Suez', 'SUZ', 'Suez', 5, 51),

-- El Salvador Departments (Country ID: 52, Timezone ID: 31 'America/Costa_Rica')
('Ahuachapán', 'AH', 'Ahuachapán', 31, 52),
('Cabañas', 'CA', 'Sensuntepeque', 31, 52),
('Chalatenango', 'CH', 'Chalatenango', 31, 52),
('Cuscatlán', 'CU', 'Cojutepeque', 31, 52),
('La Libertad', 'LI', 'Santa Tecla', 31, 52),
('La Paz', 'PA', 'Zacatecoluca', 31, 52),
('La Unión', 'UN', 'La Unión', 31, 52),
('Morazán', 'MO', 'San Francisco Gotera', 31, 52),
('San Miguel', 'SM', 'San Miguel', 31, 52),
('San Salvador', 'SS', 'San Salvador', 31, 52),
('San Vicente', 'SV', 'San Vicente', 31, 52),
('Santa Ana', 'SA', 'Santa Ana', 31, 52),
('Sonsonate', 'SO', 'Sonsonate', 31, 52),
('Usulután', 'US', 'Usulután', 31, 52),

-- Equatorial Guinea Provinces (Country ID: 53, Timezone ID: 12 'Africa/Lagos')
('Annobón', 'AN', 'San Antonio de Palé', 12, 53),
('Bioko Norte', 'BN', 'Malabo', 12, 53),
('Bioko Sur', 'BS', 'Luba', 12, 53),
('Centro Sur', 'CS', 'Evinayong', 12, 53),
('Kié-Ntem', 'KN', 'Ebebiyín', 12, 53),
('Litoral', 'LI', 'Bata', 12, 53),
('Wele-Nzas', 'WN', 'Mongomo', 12, 53),

-- Eritrea Regions (Country ID: 54, Timezone ID: 15 'Africa/Nairobi')
('Anseba', 'AN', 'Keren', 15, 54),
('Debub', 'DU', 'Mendefera', 15, 54),
('Gash-Barka', 'GB', 'Barentu', 15, 54),
('Maekel', 'MA', 'Asmara', 15, 54),
('Northern Red Sea', 'SK', 'Massawa', 15, 54),
('Southern Red Sea', 'DK', 'Assab', 15, 54),

-- Estonia Counties (Country ID: 55, Timezone ID: 120 'Europe/Helsinki')
('Harju', '37', 'Tallinn', 120, 55),
('Hiiu', '39', 'Kärdla', 120, 55),
('Ida-Viru', '44', 'Jõhvi', 120, 55),
('Jõgeva', '49', 'Jõgeva', 120, 55),
('Järva', '51', 'Paide', 120, 55),
('Lääne', '57', 'Haapsalu', 120, 55),
('Lääne-Viru', '59', 'Rakvere', 120, 55),
('Põlva', '65', 'Põlva', 120, 55),
('Pärnu', '67', 'Pärnu', 120, 55),
('Rapla', '70', 'Rapla', 120, 55),
('Saare', '74', 'Kuressaare', 120, 55),
('Tartu', '78', 'Tartu', 120, 55),
('Valga', '82', 'Valga', 120, 55),
('Viljandi', '84', 'Viljandi', 120, 55),
('Võru', '86', 'Võru', 120, 55),

-- Eswatini Regions (Country ID: 56, Timezone ID: 9 'Africa/Johannesburg')
('Hhohho', 'HH', 'Mbabane', 9, 56),
('Lubombo', 'LU', 'Siteki', 9, 56),
('Manzini', 'MA', 'Manzini', 9, 56),
('Shiselweni', 'SH', 'Nhlangano', 9, 56),

-- Ethiopia Regions (Country ID: 57, Timezone ID: 15 'Africa/Nairobi')
('Addis Ababa', 'AA', 'Addis Ababa', 15, 57),
('Afar', 'AF', 'Semera', 15, 57),
('Amhara', 'AM', 'Bahir Dar', 15, 57),
('Benishangul-Gumuz', 'BE', 'Asosa', 15, 57),
('Dire Dawa', 'DD', 'Dire Dawa', 15, 57),
('Gambela', 'GA', 'Gambela', 15, 57),
('Harari', 'HA', 'Harar', 15, 57),
('Oromia', 'OR', 'Addis Ababa', 15, 57),
('Sidama', 'SI', 'Hawassa', 15, 57),
('Somali', 'SO', 'Jijiga', 15, 57),
('Southern Nations, Nationalities, and Peoples'' Region', 'SN', 'Hawassa', 15, 57),
('Tigray', 'TI', 'Mek''ele', 15, 57),

-- Fiji Divisions (Country ID: 58, Timezone ID: 140 'Pacific/Fiji')
('Central', 'C', 'Suva', 140, 58),
('Eastern', 'E', 'Levuka', 140, 58),
('Northern', 'N', 'Labasa', 140, 58),
('Rotuma', 'R', 'Ahau', 140, 58),
('Western', 'W', 'Lautoka', 140, 58),

-- Finland Regions (Country ID: 59, Timezone ID: 120 'Europe/Helsinki')
('Åland Islands', '01', 'Mariehamn', 120, 59),
('Central Finland', '08', 'Jyväskylä', 120, 59),
('Central Ostrobothnia', '07', 'Kokkola', 120, 59),
('Kainuu', '05', 'Kajaani', 120, 59),
('Kymenlaakso', '09', 'Kotka', 120, 59),
('Lapland', '10', 'Rovaniemi', 120, 59),
('North Karelia', '13', 'Joensuu', 120, 59),
('Northern Ostrobothnia', '14', 'Oulu', 120, 59),
('Northern Savonia', '15', 'Kuopio', 120, 59),
('Ostrobothnia', '12', 'Vaasa', 120, 59),
('Päijänne Tavastia', '16', 'Lahti', 120, 59),
('Pirkanmaa', '11', 'Tampere', 120, 59),
('Satakunta', '17', 'Pori', 120, 59),
('South Karelia', '02', 'Lappeenranta', 120, 59),
('Southern Ostrobothnia', '03', 'Seinäjoki', 120, 59),
('Southern Savonia', '04', 'Mikkeli', 120, 59),
('Tavastia Proper', '06', 'Hämeenlinna', 120, 59),
('Uusimaa', '18', 'Helsinki', 120, 59),
('Finland Proper', '19', 'Turku', 120, 59),

-- Gabon Provinces (Country ID: 61, Timezone ID: 12 'Africa/Lagos')
('Estuaire', '1', 'Libreville', 12, 61),
('Haut-Ogooué', '2', 'Franceville', 12, 61),
('Moyen-Ogooué', '3', 'Lambaréné', 12, 61),
('Ngounié', '4', 'Mouila', 12, 61),
('Nyanga', '5', 'Tchibanga', 12, 61),
('Ogooué-Ivindo', '6', 'Makokou', 12, 61),
('Ogooué-Lolo', '7', 'Koulamoutou', 12, 61),
('Ogooué-Maritime', '8', 'Port-Gentil', 12, 61),
('Woleu-Ntem', '9', 'Oyem', 12, 61),

-- Gambia Regions (Country ID: 62, Timezone ID: 1 'Africa/Abidjan')
('Banjul', 'B', 'Banjul', 1, 62),
('Central River', 'M', 'Janjanbureh', 1, 62),
('Lower River', 'L', 'Mansa Konko', 1, 62),
('North Bank', 'N', 'Kerewan', 1, 62),
('Upper River', 'U', 'Basse Santa Su', 1, 62),
('West Coast', 'W', 'Brikama', 1, 62),

-- Georgia Regions (Country ID: 63, Timezone ID: 70 'Asia/Dubai')
('Abkhazia', 'AB', 'Sukhumi', 70, 63),
('Adjara', 'AJ', 'Batumi', 70, 63),
('Guria', 'GU', 'Ozurgeti', 70, 63),
('Imereti', 'IM', 'Kutaisi', 70, 63),
('Kakheti', 'KA', 'Telavi', 70, 63),
('Kvemo Kartli', 'KK', 'Rustavi', 70, 63),
('Mtskheta-Mtianeti', 'MM', 'Mtskheta', 70, 63),
('Racha-Lechkhumi and Kvemo Svaneti', 'RL', 'Ambrolauri', 70, 63),
('Samegrelo-Zemo Svaneti', 'SZ', 'Zugdidi', 70, 63),
('Samtskhe-Javakheti', 'SJ', 'Akhaltsikhe', 70, 63),
('Shida Kartli', 'SK', 'Gori', 70, 63),
('Tbilisi', 'TB', 'Tbilisi', 70, 63),

-- Ghana Regions (Country ID: 65, Timezone ID: 2 'Africa/Accra')
('Ahafo', 'AF', 'Goaso', 2, 65),
('Ashanti', 'AS', 'Kumasi', 2, 65),
('Bono', 'BO', 'Sunyani', 2, 65),
('Bono East', 'BE', 'Techiman', 2, 65),
('Central', 'CP', 'Cape Coast', 2, 65),
('Eastern', 'EP', 'Koforidua', 2, 65),
('Greater Accra', 'AA', 'Accra', 2, 65),
('North East', 'NE', 'Nalerigu', 2, 65),
('Northern', 'NP', 'Tamale', 2, 65),
('Oti', 'OT', 'Dambai', 2, 65),
('Savannah', 'SV', 'Damongo', 2, 65),
('Upper East', 'UE', 'Bolgatanga', 2, 65),
('Upper West', 'UW', 'Wa', 2, 65),
('Volta', 'TV', 'Ho', 2, 65),
('Western', 'WP', 'Sekondi-Takoradi', 2, 65),
('Western North', 'WN', 'Sefwi Wiawso', 2, 65),

-- Greece Regions (Country ID: 66, Timezone ID: 113 'Europe/Athens')
('Attica', 'I', 'Athens', 113, 66),
('Central Greece', 'H', 'Lamia', 113, 66),
('Central Macedonia', 'B', 'Thessaloniki', 113, 66),
('Crete', 'M', 'Heraklion', 113, 66),
('East Macedonia and Thrace', 'A', 'Komotini', 113, 66),
('Epirus', 'D', 'Ioannina', 113, 66),
('Ionian Islands', 'F', 'Corfu', 113, 66),
('Mount Athos', '69', 'Karyes', 113, 66),
('North Aegean', 'K', 'Mytilene', 113, 66),
('Peloponnese', 'J', 'Tripoli', 113, 66),
('South Aegean', 'L', 'Ermoupoli', 113, 66),
('Thessaly', 'E', 'Larissa', 113, 66),
('West Greece', 'G', 'Patras', 113, 66),
('West Macedonia', 'C', 'Kozani', 113, 66),

-- Grenada Parishes (Country ID: 67, Timezone ID: 45 'America/Port_of_Spain')
('Saint Andrew', '01', 'Grenville', 45, 67),
('Saint David', '02', 'St. David''s', 45, 67),
('Saint George', '03', 'St. George''s', 45, 67),
('Saint John', '04', 'Gouyave', 45, 67),
('Saint Mark', '05', 'Victoria', 45, 67),
('Saint Patrick', '06', 'Sauteurs', 45, 67),
('Southern Grenadine Islands', '10', 'Hillsborough', 45, 67),

-- Guatemala Departments (Country ID: 68, Timezone ID: 31 'America/Costa_Rica')
('Alta Verapaz', 'AV', 'Cobán', 31, 68),
('Baja Verapaz', 'BV', 'Salamá', 31, 68),
('Chimaltenango', 'CM', 'Chimaltenango', 31, 68),
('Chiquimula', 'CQ', 'Chiquimula', 31, 68),
('El Progreso', 'PR', 'Guastatoya', 31, 68),
('Escuintla', 'ES', 'Escuintla', 31, 68),
('Guatemala', 'GU', 'Guatemala City', 31, 68),
('Huehuetenango', 'HU', 'Huehuetenango', 31, 68),
('Izabal', 'IZ', 'Puerto Barrios', 31, 68),
('Jalapa', 'JA', 'Jalapa', 31, 68),
('Jutiapa', 'JU', 'Jutiapa', 31, 68),
('Petén', 'PE', 'Flores', 31, 68),
('Quetzaltenango', 'QZ', 'Quetzaltenango', 31, 68),
('Quiché', 'QC', 'Santa Cruz del Quiché', 31, 68),
('Retalhuleu', 'RE', 'Retalhuleu', 31, 68),
('Sacatepéquez', 'SA', 'Antigua Guatemala', 31, 68),
('San Marcos', 'SM', 'San Marcos', 31, 68),
('Santa Rosa', 'SR', 'Cuilapa', 31, 68),
('Sololá', 'SO', 'Sololá', 31, 68),
('Suchitepéquez', 'SU', 'Mazatenango', 31, 68),
('Totonicapán', 'TO', 'Totonicapán', 31, 68),
('Zacapa', 'ZA', 'Zacapa', 31, 68),

-- Guinea Regions (Country ID: 69, Timezone ID: 1 'Africa/Abidjan')
('Boké', 'B', 'Boké', 1, 69),
('Conakry', 'C', 'Conakry', 1, 69),
('Faranah', 'F', 'Faranah', 1, 69),
('Kankan', 'K', 'Kankan', 1, 69),
('Kindia', 'D', 'Kindia', 1, 69),
('Labé', 'L', 'Labé', 1, 69),
('Mamou', 'M', 'Mamou', 1, 69),
('Nzérékoré', 'N', 'Nzérékoré', 1, 69),

-- Guinea-Bissau Regions (Country ID: 70, Timezone ID: 4 'Africa/Bissau')
('Bafatá', 'BA', 'Bafatá', 4, 70),
('Biombo', 'BM', 'Quinhámel', 4, 70),
('Bissau', 'BS', 'Bissau', 4, 70),
('Bolama', 'BL', 'Bolama', 4, 70),
('Cacheu', 'CA', 'Cacheu', 4, 70),
('Gabú', 'GA', 'Gabú', 4, 70),
('Oio', 'OI', 'Farim', 4, 70),
('Quinara', 'QU', 'Buba', 4, 70),
('Tombali', 'TO', 'Catió', 4, 70),

-- Guyana Regions (Country ID: 71, Timezone ID: 29 'America/Caracas')
('Barima-Waini', 'BA', 'Mabaruma', 29, 71),
('Cuyuni-Mazaruni', 'CU', 'Bartica', 29, 71),
('Demerara-Mahaica', 'DE', 'Georgetown', 29, 71),
('East Berbice-Corentyne', 'EB', 'New Amsterdam', 29, 71),
('Essequibo Islands-West Demerara', 'ES', 'Vreed en Hoop', 29, 71),
('Mahaica-Berbice', 'MA', 'Fort Wellington', 29, 71),
('Pomeroon-Supenaam', 'PM', 'Anna Regina', 29, 71),
('Potaro-Siparuni', 'PT', 'Mahdia', 29, 71),
('Upper Demerara-Berbice', 'UD', 'Linden', 29, 71),
('Upper Takutu-Upper Essequibo', 'UT', 'Lethem', 29, 71),

-- Haiti Departments (Country ID: 72, Timezone ID: 44 'America/Port-au-Prince')
('Artibonite', 'AR', 'Gonaïves', 44, 72),
('Centre', 'CE', 'Hinche', 44, 72),
('Grand''Anse', 'GA', 'Jérémie', 44, 72),
('Nippes', 'NI', 'Miragoâne', 44, 72),
('Nord', 'ND', 'Cap-Haïtien', 44, 72),
('Nord-Est', 'NE', 'Fort-Liberté', 44, 72),
('Nord-Ouest', 'NO', 'Port-de-Paix', 44, 72),
('Ouest', 'OU', 'Port-au-Prince', 44, 72),
('Sud', 'SD', 'Les Cayes', 44, 72),
('Sud-Est', 'SE', 'Jacmel', 44, 72),

-- Honduras Departments (Country ID: 73, Timezone ID: 31 'America/Costa_Rica')
('Atlántida', 'AT', 'La Ceiba', 31, 73),
('Choluteca', 'CH', 'Choluteca', 31, 73),
('Colón', 'CL', 'Trujillo', 31, 73),
('Comayagua', 'CM', 'Comayagua', 31, 73),
('Copán', 'CP', 'Santa Rosa de Copán', 31, 73),
('Cortés', 'CR', 'San Pedro Sula', 31, 73),
('El Paraíso', 'EP', 'Yuscarán', 31, 73),
('Francisco Morazán', 'FM', 'Tegucigalpa', 31, 73),
('Gracias a Dios', 'GD', 'Puerto Lempira', 31, 73),
('Intibucá', 'IN', 'La Esperanza', 31, 73),
('Islas de la Bahía', 'IB', 'Roatán', 31, 73),
('La Paz', 'LP', 'La Paz', 31, 73),
('Lempira', 'LE', 'Gracias', 31, 73),
('Ocotepeque', 'OC', 'Ocotepeque', 31, 73),
('Olancho', 'OL', 'Juticalpa', 31, 73),
('Santa Bárbara', 'SB', 'Santa Bárbara', 31, 73),
('Valle', 'VA', 'Nacaome', 31, 73),
('Yoro', 'YO', 'Yoro', 31, 73),

-- Hungary Counties (Country ID: 74, Timezone ID: 117 'Europe/Budapest')
('Bács-Kiskun', 'BK', 'Kecskemét', 117, 74),
('Baranya', 'BA', 'Pécs', 117, 74),
('Békés', 'BE', 'Békéscsaba', 117, 74),
('Borsod-Abaúj-Zemplén', 'BZ', 'Miskolc', 117, 74),
('Budapest', 'BU', 'Budapest', 117, 74),
('Csongrád-Csanád', 'CS', 'Szeged', 117, 74),
('Fejér', 'FE', 'Székesfehérvár', 117, 74),
('Győr-Moson-Sopron', 'GS', 'Győr', 117, 74),
('Hajdú-Bihar', 'HB', 'Debrecen', 117, 74),
('Heves', 'HE', 'Eger', 117, 74),
('Jász-Nagykun-Szolnok', 'JN', 'Szolnok', 117, 74),
('Komárom-Esztergom', 'KE', 'Tatabánya', 117, 74),
('Nógrád', 'NO', 'Salgótarján', 117, 74),
('Pest', 'PE', 'Budapest', 117, 74),
('Somogy', 'SO', 'Kaposvár', 117, 74),
('Szabolcs-Szatmár-Bereg', 'SZ', 'Nyíregyháza', 117, 74),
('Tolna', 'TO', 'Szekszárd', 117, 74),
('Vas', 'VA', 'Szombathely', 117, 74),
('Veszprém', 'VE', 'Veszprém', 117, 74),
('Zala', 'ZA', 'Zalaegerszeg', 117, 74),

-- Iceland Regions (Country ID: 75, Timezone ID: 102 'Atlantic/Reykjavik')
('Capital Region', '1', 'Reykjavík', 102, 75),
('Southern Peninsula', '2', 'Keflavík', 102, 75),
('Western Region', '3', 'Borgarnes', 102, 75),
('Westfjords', '4', 'Ísafjörður', 102, 75),
('Northwestern Region', '5', 'Sauðárkrókur', 102, 75),
('Northeastern Region', '6', 'Akureyri', 102, 75),
('Eastern Region', '7', 'Egilsstaðir', 102, 75),
('Southern Region', '8', 'Selfoss', 102, 75),

-- Indonesia Provinces (Country ID: 77, Timezone ID: 74 'Asia/Jakarta')
('Aceh', 'AC', 'Banda Aceh', 74, 77),
('Bali', 'BA', 'Denpasar', 74, 77),
('Bangka Belitung Islands', 'BB', 'Pangkal Pinang', 74, 77),
('Banten', 'BT', 'Serang', 74, 77),
('Bengkulu', 'BE', 'Bengkulu', 74, 77),
('Central Java', 'JT', 'Semarang', 74, 77),
('Central Kalimantan', 'KT', 'Palangka Raya', 74, 77),
('Central Sulawesi', 'ST', 'Palu', 74, 77),
('East Java', 'JI', 'Surabaya', 74, 77),
('East Kalimantan', 'KI', 'Samarinda', 74, 77),
('East Nusa Tenggara', 'NT', 'Kupang', 74, 77),
('Gorontalo', 'GO', 'Gorontalo', 74, 77),
('Jakarta', 'JK', 'Jakarta', 74, 77),
('Jambi', 'JA', 'Jambi', 74, 77),
('Lampung', 'LA', 'Bandar Lampung', 74, 77),
('Maluku', 'MA', 'Ambon', 74, 77),
('North Kalimantan', 'KU', 'Tanjung Selor', 74, 77),
('North Maluku', 'MU', 'Sofifi', 74, 77),
('North Sulawesi', 'SA', 'Manado', 74, 77),
('North Sumatra', 'SU', 'Medan', 74, 77),
('Papua', 'PA', 'Jayapura', 74, 77),
('Riau', 'RI', 'Pekanbaru', 74, 77),
('Riau Islands', 'KR', 'Tanjung Pinang', 74, 77),
('Southeast Sulawesi', 'SG', 'Kendari', 74, 77),
('South Kalimantan', 'KS', 'Banjarmasin', 74, 77),
('South Sulawesi', 'SN', 'Makassar', 74, 77),
('South Sumatra', 'SS', 'Palembang', 74, 77),
('West Java', 'JB', 'Bandung', 74, 77),
('West Kalimantan', 'KB', 'Pontianak', 74, 77),
('West Nusa Tenggara', 'NB', 'Mataram', 74, 77),
('West Papua', 'PB', 'Manokwari', 74, 77),
('West Sulawesi', 'SR', 'Mamuju', 74, 77),
('West Sumatra', 'SB', 'Padang', 74, 77),
('Yogyakarta', 'YO', 'Yogyakarta', 74, 77),

-- Iran Provinces (Country ID: 78, Timezone ID: 91 'Asia/Tehran')
('Alborz', '30', 'Karaj', 91, 78),
('Ardabil', '24', 'Ardabil', 91, 78),
('Bushehr', '18', 'Bushehr', 91, 78),
('Chaharmahal and Bakhtiari', '14', 'Shahr-e Kord', 91, 78),
('East Azerbaijan', '03', 'Tabriz', 91, 78),
('Fars', '07', 'Shiraz', 91, 78),
('Gilan', '01', 'Rasht', 91, 78),
('Golestan', '27', 'Gorgan', 91, 78),
('Hamadan', '13', 'Hamadan', 91, 78),
('Hormozgan', '22', 'Bandar Abbas', 91, 78),
('Ilam', '16', 'Ilam', 91, 78),
('Isfahan', '10', 'Isfahan', 91, 78),
('Kerman', '08', 'Kerman', 91, 78),
('Kermanshah', '05', 'Kermanshah', 91, 78),
('Khuzestan', '06', 'Ahvaz', 91, 78),
('Kohgiluyeh and Boyer-Ahmad', '17', 'Yasuj', 91, 78),
('Kurdistan', '12', 'Sanandaj', 91, 78),
('Lorestan', '15', 'Khorramabad', 91, 78),
('Markazi', '00', 'Arak', 91, 78),
('Mazandaran', '02', 'Sari', 91, 78),
('North Khorasan', '28', 'Bojnord', 91, 78),
('Qazvin', '26', 'Qazvin', 91, 78),
('Qom', '25', 'Qom', 91, 78),
('Razavi Khorasan', '09', 'Mashhad', 91, 78),
('Semnan', '20', 'Semnan', 91, 78),
('Sistan and Baluchestan', '11', 'Zahedan', 91, 78),
('South Khorasan', '29', 'Birjand', 91, 78),
('Tehran', '23', 'Tehran', 91, 78),
('West Azerbaijan', '04', 'Urmia', 91, 78),
('Yazd', '21', 'Yazd', 91, 78),
('Zanjan', '19', 'Zanjan', 91, 78),

-- Iraq Governorates (Country ID: 79, Timezone ID: 65 'Asia/Baghdad')
('Al Anbar', 'AN', 'Ramadi', 65, 79),
('Al Muthanna', 'MU', 'Samawah', 65, 79),
('Al-Qādisiyyah', 'QA', 'Diwaniyah', 65, 79),
('Babylon', 'BB', 'Hillah', 65, 79),
('Baghdad', 'BG', 'Baghdad', 65, 79),
('Basra', 'BA', 'Basra', 65, 79),
('Dhi Qar', 'DQ', 'Nasiriyah', 65, 79),
('Diyala', 'DI', 'Baqubah', 65, 79),
('Dohuk', 'DA', 'Dohuk', 65, 79),
('Erbil', 'AR', 'Erbil', 65, 79),
('Karbala', 'KA', 'Karbala', 65, 79),
('Kirkuk', 'KI', 'Kirkuk', 65, 79),
('Maysan', 'MA', 'Amarah', 65, 79),
('Najaf', 'NA', 'Najaf', 65, 79),
('Nineveh', 'NI', 'Mosul', 65, 79),
('Saladin', 'SD', 'Tikrit', 65, 79),
('Sulaymaniyah', 'SU', 'Sulaymaniyah', 65, 79),
('Wasit', 'WA', 'Kut', 65, 79),

-- Ireland Provinces (Country ID: 80, Timezone ID: 119 'Europe/Dublin')
('Connacht', 'C', 'Galway', 119, 80),
('Leinster', 'L', 'Dublin', 119, 80),
('Munster', 'M', 'Cork', 119, 80),
('Ulster', 'U', 'Monaghan', 119, 80),

-- Israel Districts (Country ID: 81, Timezone ID: 75 'Asia/Jerusalem')
('Central', 'M', 'Ramla', 75, 81),
('Haifa', 'HA', 'Haifa', 75, 81),
('Jerusalem', 'JM', 'Jerusalem', 75, 81),
('Northern', 'Z', 'Nazareth', 75, 81),
('Southern', 'D', 'Beersheba', 75, 81),
('Tel Aviv', 'TA', 'Tel Aviv', 75, 81),

-- Italy Regions (Country ID: 82, Timezone ID: 129 'Europe/Rome')
('Abruzzo', '65', 'L''Aquila', 129, 82),
('Aosta Valley', '23', 'Aosta', 129, 82),
('Apulia', '75', 'Bari', 129, 82),
('Basilicata', '77', 'Potenza', 129, 82),
('Calabria', '78', 'Catanzaro', 129, 82),
('Campania', '72', 'Naples', 129, 82),
('Emilia-Romagna', '45', 'Bologna', 129, 82),
('Friuli-Venezia Giulia', '36', 'Trieste', 129, 82),
('Lazio', '62', 'Rome', 129, 82),
('Liguria', '42', 'Genoa', 129, 82),
('Lombardy', '25', 'Milan', 129, 82),
('Marche', '57', 'Ancona', 129, 82),
('Molise', '67', 'Campobasso', 129, 82),
('Piedmont', '21', 'Turin', 129, 82),
('Sardinia', '88', 'Cagliari', 129, 82),
('Sicily', '82', 'Palermo', 129, 82),
('Trentino-Alto Adige/Südtirol', '32', 'Trento', 129, 82),
('Tuscany', '52', 'Florence', 129, 82),
('Umbria', '55', 'Perugia', 129, 82),
('Veneto', '34', 'Venice', 129, 82),

-- Jamaica Parishes (Country ID: 83, Timezone ID: 44 'America/Port-au-Prince')
('Clarendon', '13', 'May Pen', 44, 83),
('Hanover', '09', 'Lucea', 44, 83),
('Kingston', '01', 'Kingston', 44, 83),
('Manchester', '12', 'Mandeville', 44, 83),
('Portland', '04', 'Port Antonio', 44, 83),
('Saint Andrew', '02', 'Half Way Tree', 44, 83),
('Saint Ann', '06', 'Saint Ann''s Bay', 44, 83),
('Saint Catherine', '14', 'Spanish Town', 44, 83),
('Saint Elizabeth', '11', 'Black River', 44, 83),
('Saint James', '08', 'Montego Bay', 44, 83),
('Saint Mary', '05', 'Port Maria', 44, 83),
('Saint Thomas', '03', 'Morant Bay', 44, 83),
('Trelawny', '07', 'Falmouth', 44, 83),
('Westmoreland', '10', 'Savanna-la-Mar', 44, 83),

-- Jordan Governorates (Country ID: 85, Timezone ID: 61 'Asia/Amman')
('Ajloun', 'AJ', 'Ajloun', 61, 85),
('Amman', 'AM', 'Amman', 61, 85),
('Aqaba', 'AQ', 'Aqaba', 61, 85),
('Balqa', 'BA', 'Salt', 61, 85),
('Irbid', 'IR', 'Irbid', 61, 85),
('Jerash', 'JA', 'Jerash', 61, 85),
('Karak', 'KA', 'Karak', 61, 85),
('Ma''an', 'MN', 'Ma''an', 61, 85),
('Madaba', 'MD', 'Madaba', 61, 85),
('Mafraq', 'MA', 'Mafraq', 61, 85),
('Tafilah', 'AT', 'Tafilah', 61, 85),
('Zarqa', 'AZ', 'Zarqa', 61, 85),

-- Kazakhstan Regions (Country ID: 86, Timezone ID: 60 'Asia/Almaty')
('Akmola', 'AKM', 'Kokshetau', 60, 86),
('Aktobe', 'AKT', 'Aktobe', 60, 86),
('Almaty', 'ALM', 'Taldykorgan', 60, 86),
('Atyrau', 'ATY', 'Atyrau', 60, 86),
('East Kazakhstan', 'VOS', 'Oskemen', 60, 86),
('Jambyl', 'ZHA', 'Taraz', 60, 86),
('Karaganda', 'KAR', 'Karaganda', 60, 86),
('Kostanay', 'KUS', 'Kostanay', 60, 86),
('Kyzylorda', 'KZY', 'Kyzylorda', 60, 86),
('Mangystau', 'MAN', 'Aktau', 60, 86),
('North Kazakhstan', 'SEV', 'Petropavl', 60, 86),
('Pavlodar', 'PAV', 'Pavlodar', 60, 86),
('Turkistan', 'YUZ', 'Turkistan', 60, 86),
('West Kazakhstan', 'ZAP', 'Oral', 60, 86),
('Almaty City', 'ALA', 'Almaty', 60, 86),
('Astana City', 'AST', 'Astana', 60, 86),
('Shymkent City', 'SHY', 'Shymkent', 60, 86),

-- Kenya Counties (Country ID: 87, Timezone ID: 15 'Africa/Nairobi')
('Baringo', '01', 'Kabarnet', 15, 87),
('Bomet', '02', 'Bomet', 15, 87),
('Bungoma', '03', 'Bungoma', 15, 87),
('Busia', '04', 'Busia', 15, 87),
('Elgeyo-Marakwet', '05', 'Iten', 15, 87),
('Embu', '06', 'Embu', 15, 87),
('Garissa', '07', 'Garissa', 15, 87),
('Homa Bay', '08', 'Homa Bay', 15, 87),
('Isiolo', '09', 'Isiolo', 15, 87),
('Kajiado', '10', 'Kajiado', 15, 87),
('Kakamega', '11', 'Kakamega', 15, 87),
('Kericho', '12', 'Kericho', 15, 87),
('Kiambu', '13', 'Kiambu', 15, 87),
('Kilifi', '14', 'Kilifi', 15, 87),
('Kirinyaga', '15', 'Kerugoya', 15, 87),
('Kisii', '16', 'Kisii', 15, 87),
('Kisumu', '17', 'Kisumu', 15, 87),
('Kitui', '18', 'Kitui', 15, 87),
('Kwale', '19', 'Kwale', 15, 87),
('Laikipia', '20', 'Nanyuki', 15, 87),
('Lamu', '21', 'Lamu', 15, 87),
('Machakos', '22', 'Machakos', 15, 87),
('Makueni', '23', 'Wote', 15, 87),
('Mandera', '24', 'Mandera', 15, 87),
('Marsabit', '25', 'Marsabit', 15, 87),
('Meru', '26', 'Meru', 15, 87),
('Migori', '27', 'Migori', 15, 87),
('Mombasa', '28', 'Mombasa', 15, 87),
('Murang''a', '29', 'Murang''a', 15, 87),
('Nairobi', '30', 'Nairobi', 15, 87),
('Nakuru', '31', 'Nakuru', 15, 87),
('Nandi', '32', 'Kapsabet', 15, 87),
('Narok', '33', 'Narok', 15, 87),
('Nyamira', '34', 'Nyamira', 15, 87),
('Nyandarua', '35', 'Ol Kalou', 15, 87),
('Nyeri', '36', 'Nyeri', 15, 87),
('Samburu', '37', 'Maralal', 15, 87),
('Siaya', '38', 'Siaya', 15, 87),
('Taita-Taveta', '39', 'Voi', 15, 87),
('Tana River', '40', 'Hola', 15, 87),
('Tharaka-Nithi', '41', 'Chuka', 15, 87),
('Trans Nzoia', '42', 'Kitale', 15, 87),
('Turkana', '43', 'Lodwar', 15, 87),
('Uasin Gishu', '44', 'Eldoret', 15, 87),
('Vihiga', '45', 'Vihiga', 15, 87),
('Wajir', '46', 'Wajir', 15, 87),
('West Pokot', '47', 'Kapenguria', 15, 87),

-- Kiribati Island groups (Country ID: 88, Timezone ID: 142 'Pacific/Kiritimati')
('Gilbert Islands', 'G', 'Tarawa', 142, 88),
('Line Islands', 'L', 'Kiritimati', 142, 88),
('Phoenix Islands', 'P', 'Kanton', 142, 88),

-- Kuwait Governorates (Country ID: 89, Timezone ID: 87 'Asia/Riyadh')
('Al Ahmadi', 'AH', 'Al Ahmadi', 87, 89),
('Al Farwaniyah', 'FA', 'Al Farwaniyah', 87, 89),
('Al Jahra', 'JA', 'Al Jahra', 87, 89),
('Al Asimah', 'KU', 'Kuwait City', 87, 89),
('Hawalli', 'HA', 'Hawalli', 87, 89),
('Mubarak Al-Kabeer', 'MU', 'Mubarak Al-Kabeer', 87, 89),

-- Kyrgyzstan Regions (Country ID: 90, Timezone ID: 67 'Asia/Bishkek')
('Batken', 'B', 'Batken', 67, 90),
('Chuy', 'C', 'Bishkek', 67, 90),
('Issyk-Kul', 'Y', 'Karakol', 67, 90),
('Jalal-Abad', 'J', 'Jalal-Abad', 67, 90),
('Naryn', 'N', 'Naryn', 67, 90),
('Osh', 'O', 'Osh', 67, 90),
('Talas', 'T', 'Talas', 67, 90),
('Bishkek City', 'GB', 'Bishkek', 67, 90),

-- Laos Provinces (Country ID: 91, Timezone ID: 66 'Asia/Bangkok')
('Attapeu', 'AT', 'Attapeu', 66, 91),
('Bokeo', 'BK', 'Houayxay', 66, 91),
('Bolikhamsai', 'BL', 'Paksan', 66, 91),
('Champasak', 'CH', 'Pakse', 66, 91),
('Houaphanh', 'HO', 'Xam Neua', 66, 91),
('Khammouane', 'KH', 'Thakhek', 66, 91),
('Luang Namtha', 'LM', 'Luang Namtha', 66, 91),
('Luang Prabang', 'LP', 'Luang Prabang', 66, 91),
('Oudomxay', 'OU', 'Muang Xay', 66, 91),
('Phongsaly', 'PH', 'Phongsaly', 66, 91),
('Sainyabuli', 'XA', 'Sainyabuli', 66, 91),
('Salavan', 'SL', 'Salavan', 66, 91),
('Savannakhet', 'SV', 'Savannakhet', 66, 91),
('Sekong', 'XE', 'Sekong', 66, 91),
('Vientiane Prefecture', 'VT', 'Vientiane', 66, 91),
('Vientiane Province', 'VI', 'Phonhong', 66, 91),
('Xaisomboun', 'XS', 'Anouvong', 66, 91),
('Xiangkhouang', 'XI', 'Phonsavan', 66, 91),

-- Latvia Municipalities (Country ID: 92, Timezone ID: 120 'Europe/Helsinki')
('Aglona', '001', 'Aglona', 120, 92),
('Aizkraukle', '002', 'Aizkraukle', 120, 92),
('Aizpute', '003', 'Aizpute', 120, 92),
('Aknīste', '004', 'Aknīste', 120, 92),
('Aloja', '005', 'Aloja', 120, 92),
('Alsunga', '006', 'Alsunga', 120, 92),
('Alūksne', '007', 'Alūksne', 120, 92),
('Amata', '008', 'Amata', 120, 92),
('Ape', '009', 'Ape', 120, 92),
('Auce', '010', 'Auce', 120, 92),
('Ādaži', '011', 'Ādaži', 120, 92),
('Babīte', '012', 'Babīte', 120, 92),
('Baldone', '013', 'Baldone', 120, 92),
('Baltinava', '014', 'Baltinava', 120, 92),
('Balvi', '015', 'Balvi', 120, 92),
('Bauska', '016', 'Bauska', 120, 92),
('Beverīna', '017', 'Beverīna', 120, 92),
('Brocēni', '018', 'Brocēni', 120, 92),
('Burtnieki', '019', 'Burtnieki', 120, 92),
('Carnikava', '020', 'Carnikava', 120, 92),
('Cēsis', '022', 'Cēsis', 120, 92),
('Cesvaine', '021', 'Cesvaine', 120, 92),
('Cibla', '023', 'Cibla', 120, 92),
('Dagda', '024', 'Dagda', 120, 92),
('Daugavpils', '025', 'Daugavpils', 120, 92),
('Daugavpils City', 'DGV', 'Daugavpils', 120, 92),
('Dobele', '026', 'Dobele', 120, 92),
('Dundaga', '027', 'Dundaga', 120, 92),
('Durbe', '028', 'Durbe', 120, 92),
('Engure', '029', 'Engure', 120, 92),
('Ērgļi', '030', 'Ērgļi', 120, 92),
('Garkalne', '031', 'Garkalne', 120, 92),
('Grobiņa', '032', 'Grobiņa', 120, 92),
('Gulbene', '033', 'Gulbene', 120, 92),
('Iecava', '034', 'Iecava', 120, 92),
('Ikšķile', '035', 'Ikšķile', 120, 92),
('Ilūkste', '036', 'Ilūkste', 120, 92),
('Inčukalns', '037', 'Inčukalns', 120, 92),
('Jaunjelgava', '038', 'Jaunjelgava', 120, 92),
('Jaunpiebalga', '039', 'Jaunpiebalga', 120, 92),
('Jaunpils', '040', 'Jaunpils', 120, 92),
('Jēkabpils', '042', 'Jēkabpils', 120, 92),
('Jēkabpils City', 'JKB', 'Jēkabpils', 120, 92),
('Jelgava', '041', 'Jelgava', 120, 92),
('Jelgava City', 'JEL', 'Jelgava', 120, 92),
('Jūrmala', 'JUR', 'Jūrmala', 120, 92),
('Kandava', '043', 'Kandava', 120, 92),
('Kārsava', '044', 'Kārsava', 120, 92),
('Kocēni', '045', 'Kocēni', 120, 92),
('Koknese', '046', 'Koknese', 120, 92),
('Krāslava', '047', 'Krāslava', 120, 92),
('Krimulda', '048', 'Krimulda', 120, 92),
('Krustpils', '049', 'Krustpils', 120, 92),
('Kuldīga', '050', 'Kuldīga', 120, 92),
('Ķegums', '051', 'Ķegums', 120, 92),
('Ķekava', '052', 'Ķekava', 120, 92),
('Lielvārde', '053', 'Lielvārde', 120, 92),
('Liepāja', 'LPX', 'Liepāja', 120, 92),
('Līgatne', '055', 'Līgatne', 120, 92),
('Limbaži', '054', 'Limbaži', 120, 92),
('Līvāni', '056', 'Līvāni', 120, 92),
('Lubāna', '057', 'Lubāna', 120, 92),
('Ludza', '058', 'Ludza', 120, 92),
('Madona', '059', 'Madona', 120, 92),
('Mālpils', '060', 'Mālpils', 120, 92),
('Mārupe', '061', 'Mārupe', 120, 92),
('Mazsalaca', '062', 'Mazsalaca', 120, 92),
('Mērsrags', '063', 'Mērsrags', 120, 92),
('Naukšēni', '064', 'Naukšēni', 120, 92),
('Nereta', '065', 'Nereta', 120, 92),
('Nīca', '066', 'Nīca', 120, 92),
('Ogre', '067', 'Ogre', 120, 92),
('Olaine', '068', 'Olaine', 120, 92),
('Ozolnieki', '069', 'Ozolnieki', 120, 92),
('Pārgauja', '070', 'Pārgauja', 120, 92),
('Pāvilosta', '071', 'Pāvilosta', 120, 92),
('Pļaviņas', '072', 'Pļaviņas', 120, 92),
('Preiļi', '073', 'Preiļi', 120, 92),
('Priekule', '074', 'Priekule', 120, 92),
('Priekuļi', '075', 'Priekuļi', 120, 92),
('Rauna', '076', 'Rauna', 120, 92),
('Rēzekne', '077', 'Rēzekne', 120, 92),
('Rēzekne City', 'REZ', 'Rēzekne', 120, 92),
('Riebiņi', '078', 'Riebiņi', 120, 92),
('Rīga', 'RIX', 'Rīga', 120, 92),
('Roja', '079', 'Roja', 120, 92),
('Ropaži', '080', 'Ropaži', 120, 92),
('Rucava', '081', 'Rucava', 120, 92),
('Rugāji', '082', 'Rugāji', 120, 92),
('Rundāle', '083', 'Rundāle', 120, 92),
('Rūjiena', '084', 'Rūjiena', 120, 92),
('Sala', '085', 'Sala', 120, 92),
('Salacgrīva', '086', 'Salacgrīva', 120, 92),
('Salaspils', '087', 'Salaspils', 120, 92),
('Saldus', '088', 'Saldus', 120, 92),
('Saulkrasti', '089', 'Saulkrasti', 120, 92),
('Sēja', '090', 'Sēja', 120, 92),
('Sigulda', '091', 'Sigulda', 120, 92),
('Skrīveri', '092', 'Skrīveri', 120, 92),
('Skrunda', '093', 'Skrunda', 120, 92),
('Smiltene', '094', 'Smiltene', 120, 92),
('Stopiņi', '095', 'Stopiņi', 120, 92),
('Strenči', '096', 'Strenči', 120, 92),
('Talsi', '097', 'Talsi', 120, 92),
('Tērvete', '098', 'Tērvete', 120, 92),
('Tukums', '099', 'Tukums', 120, 92),
('Vaiņode', '100', 'Vaiņode', 120, 92),
('Valka', '101', 'Valka', 120, 92),
('Valmiera', 'VMR', 'Valmiera', 120, 92),
('Varakļāni', '102', 'Varakļāni', 120, 92),
('Vārkava', '103', 'Vārkava', 120, 92),
('Vecpiebalga', '104', 'Vecpiebalga', 120, 92),
('Vecumnieki', '105', 'Vecumnieki', 120, 92),
('Ventspils', '106', 'Ventspils', 120, 92),
('Ventspils City', 'VEN', 'Ventspils', 120, 92),
('Viesīte', '107', 'Viesīte', 120, 92),
('Viļaka', '108', 'Viļaka', 120, 92),
('Viļāni', '109', 'Viļāni', 120, 92),
('Zilupe', '110', 'Zilupe', 120, 92),

-- Lebanon Governorates (Country ID: 93, Timezone ID: 113 'Europe/Athens')
('Akkar', 'AK', 'Halba', 113, 93),
('Baalbek-Hermel', 'BH', 'Baalbek', 113, 93),
('Beirut', 'BA', 'Beirut', 113, 93),
('Beqaa', 'BI', 'Zahlé', 113, 93),
('Mount Lebanon', 'JL', 'Baabda', 113, 93),
('Nabatieh', 'NA', 'Nabatieh', 113, 93),
('North', 'AS', 'Tripoli', 113, 93),
('South', 'JA', 'Sidon', 113, 93),

-- Lesotho Districts (Country ID: 94, Timezone ID: 9 'Africa/Johannesburg')
('Berea', 'D', 'Teyateyaneng', 9, 94),
('Butha-Buthe', 'B', 'Butha-Buthe', 9, 94),
('Leribe', 'C', 'Hlotse', 9, 94),
('Mafeteng', 'E', 'Mafeteng', 9, 94),
('Maseru', 'A', 'Maseru', 9, 94),
('Mohale''s Hoek', 'F', 'Mohale''s Hoek', 9, 94),
('Mokhotlong', 'J', 'Mokhotlong', 9, 94),
('Qacha''s Nek', 'H', 'Qacha''s Nek', 9, 94),
('Quthing', 'G', 'Quthing', 9, 94),
('Thaba-Tseka', 'K', 'Thaba-Tseka', 9, 94),

-- Liberia Counties (Country ID: 95, Timezone ID: 14 'Africa/Monrovia')
('Bomi', 'BM', 'Tubmanburg', 14, 95),
('Bong', 'BG', 'Gbarnga', 14, 95),
('Gbarpolu', 'GP', 'Bopolu', 14, 95),
('Grand Bassa', 'GB', 'Buchanan', 14, 95),
('Grand Cape Mount', 'CM', 'Robertsport', 14, 95),
('Grand Gedeh', 'GG', 'Zwedru', 14, 95),
('Grand Kru', 'GK', 'Barclayville', 14, 95),
('Lofa', 'LO', 'Voinjama', 14, 95),
('Margibi', 'MG', 'Kakata', 14, 95),
('Maryland', 'MY', 'Harper', 14, 95),
('Montserrado', 'MO', 'Bensonville', 14, 95),
('Nimba', 'NI', 'Sanniquellie', 14, 95),
('River Cess', 'RI', 'River Cess', 14, 95),
('River Gee', 'RG', 'Fish Town', 14, 95),
('Sinoe', 'SI', 'Greenville', 14, 95),

-- Libya Districts (Country ID: 96, Timezone ID: 18 'Africa/Tripoli')
('Butnan', 'BU', 'Tobruk', 18, 96),
('Derna', 'DR', 'Derna', 18, 96),
('Jabal al Akhdar', 'JA', 'Bayda', 18, 96),
('Marj', 'MJ', 'Marj', 18, 96),
('Benghazi', 'BA', 'Benghazi', 18, 96),
('Al Wahat', 'WA', 'Ajdabiya', 18, 96),
('Kufra', 'KF', 'Kufra', 18, 96),
('Sirte', 'SR', 'Sirte', 18, 96),
('Misrata', 'MI', 'Misrata', 18, 96),
('Murqub', 'MB', 'Khoms', 18, 96),
('Tripoli', 'TB', 'Tripoli', 18, 96),
('Jafara', 'JI', 'Azizia', 18, 96),
('Zawiya', 'ZA', 'Zawiya', 18, 96),
('Nuqat al Khams', 'NQ', 'Zuwara', 18, 96),
('Jabal al Gharbi', 'JG', 'Gharyan', 18, 96),
('Nalut', 'NL', 'Nalut', 18, 96),
('Jufra', 'JU', 'Hun', 18, 96),
('Wadi al Shatii', 'WS', 'Brak', 18, 96),
('Sabha', 'SB', 'Sabha', 18, 96),
('Wadi al Hayaa', 'WD', 'Ubari', 18, 96),
('Ghat', 'GT', 'Ghat', 18, 96),
('Murzuq', 'MQ', 'Murzuq', 18, 96),

-- Liechtenstein Municipalities (Country ID: 97, Timezone ID: 114 'Europe/Berlin')
('Balzers', '01', 'Balzers', 114, 97),
('Eschen', '02', 'Eschen', 114, 97),
('Gamprin', '03', 'Gamprin', 114, 97),
('Mauren', '04', 'Mauren', 114, 97),
('Planken', '05', 'Planken', 114, 97),
('Ruggell', '06', 'Ruggell', 114, 97),
('Schaan', '07', 'Schaan', 114, 97),
('Schellenberg', '08', 'Schellenberg', 114, 97),
('Triesen', '09', 'Triesen', 114, 97),
('Triesenberg', '10', 'Triesenberg', 114, 97),
('Vaduz', '11', 'Vaduz', 114, 97),

-- Lithuania Counties (Country ID: 98, Timezone ID: 120 'Europe/Helsinki')
('Alytus', 'AL', 'Alytus', 120, 98),
('Kaunas', 'KA', 'Kaunas', 120, 98),
('Klaipėda', 'KL', 'Klaipėda', 120, 98),
('Marijampolė', 'MR', 'Marijampolė', 120, 98),
('Panevėžys', 'PN', 'Panevėžys', 120, 98),
('Šiauliai', 'SA', 'Šiauliai', 120, 98),
('Tauragė', 'TA', 'Tauragė', 120, 98),
('Telšiai', 'TE', 'Telšiai', 120, 98),
('Utena', 'UT', 'Utena', 120, 98),
('Vilnius', 'VL', 'Vilnius', 120, 98),

-- Luxembourg Cantons (Country ID: 99, Timezone ID: 115 'Europe/Brussels')
('Capellen', 'CA', 'Capellen', 115, 99),
('Clervaux', 'CL', 'Clervaux', 115, 99),
('Diekirch', 'DI', 'Diekirch', 115, 99),
('Echternach', 'EC', 'Echternach', 115, 99),
('Esch-sur-Alzette', 'ES', 'Esch-sur-Alzette', 115, 99),
('Grevenmacher', 'GR', 'Grevenmacher', 115, 99),
('Luxembourg', 'LU', 'Luxembourg', 115, 99),
('Mersch', 'ME', 'Mersch', 115, 99),
('Redange', 'RD', 'Redange', 115, 99),
('Remich', 'RM', 'Remich', 115, 99),
('Vianden', 'VD', 'Vianden', 115, 99),
('Wiltz', 'WI', 'Wiltz', 115, 99),

-- Madagascar Regions (Country ID: 100, Timezone ID: 15 'Africa/Nairobi')
('Diana', 'DI', 'Antsiranana', 15, 100),
('Sava', 'SA', 'Sambava', 15, 100),
('Itasy', 'IT', 'Miarinarivo', 15, 100),
('Analamanga', 'AL', 'Antananarivo', 15, 100),
('Vakinankaratra', 'VK', 'Antsirabe', 15, 100),
('Bongolava', 'BO', 'Tsiroanomandidy', 15, 100),
('Sofia', 'SO', 'Antsohihy', 15, 100),
('Boeny', 'BN', 'Mahajanga', 15, 100),
('Betsiboka', 'BE', 'Maevatanana', 15, 100),
('Melaky', 'ME', 'Maintirano', 15, 100),
('Alaotra-Mangoro', 'AM', 'Ambatondrazaka', 15, 100),
('Atsinanana', 'AT', 'Toamasina', 15, 100),
('Analanjirofo', 'AN', 'Fenoarivo Atsinanana', 15, 100),
('Amoron''i Mania', 'AM', 'Ambositra', 15, 100),
('Haute Matsiatra', 'HM', 'Fianarantsoa', 15, 100),
('Vatovavy-Fitovinany', 'VF', 'Manakara', 15, 100),
('Atsimo-Atsinanana', 'AA', 'Farafangana', 15, 100),
('Ihorombe', 'IH', 'Ihosy', 15, 100),
('Menabe', 'MN', 'Morondava', 15, 100),
('Atsimo-Andrefana', 'AS', 'Toliara', 15, 100),
('Androy', 'AD', 'Ambovombe', 15, 100),
('Anosy', 'AN', 'Tôlanaro', 15, 100),

-- Malawi Regions (Country ID: 101, Timezone ID: 13 'Africa/Maputo')
('Central Region', 'C', 'Lilongwe', 13, 101),
('Northern Region', 'N', 'Mzuzu', 13, 101),
('Southern Region', 'S', 'Blantyre', 13, 101),

-- Malaysia States and Federal Territories (Country ID: 102, Timezone ID: 81 'Asia/Kuala_Lumpur')
('Johor', '01', 'Johor Bahru', 81, 102),
('Kedah', '02', 'Alor Setar', 81, 102),
('Kelantan', '03', 'Kota Bharu', 81, 102),
('Kuala Lumpur', '14', 'Kuala Lumpur', 81, 102),
('Labuan', '15', 'Victoria', 81, 102),
('Melaka', '04', 'Malacca City', 81, 102),
('Negeri Sembilan', '05', 'Seremban', 81, 102),
('Pahang', '06', 'Kuantan', 81, 102),
('Penang', '07', 'George Town', 81, 102),
('Perak', '08', 'Ipoh', 81, 102),
('Perlis', '09', 'Kangar', 81, 102),
('Putrajaya', '16', 'Putrajaya', 81, 102),
('Sabah', '12', 'Kota Kinabalu', 81, 102),
('Sarawak', '13', 'Kuching', 81, 102),
('Selangor', '10', 'Shah Alam', 81, 102),
('Terengganu', '11', 'Kuala Terengganu', 81, 102),

-- Maldives Atolls (Country ID: 103, Timezone ID: 63 'Asia/Ashgabat')
('Addu Atoll', '01', 'Hithadhoo', 63, 103),
('Alif Alif Atoll', '02', 'Rasdhoo', 63, 103),
('Alif Dhaal Atoll', '00', 'Mahibadhoo', 63, 103),
('Baa Atoll', '20', 'Eydhafushi', 63, 103),
('Dhaalu Atoll', '17', 'Kudahuvadhoo', 63, 103),
('Faafu Atoll', '14', 'Nilandhoo', 63, 103),
('Gaafu Alif Atoll', '27', 'Vilingili', 63, 103),
('Gaafu Dhaalu Atoll', '28', 'Thinadhoo', 63, 103),
('Gnaviyani Atoll', '29', 'Fuvahmulah', 63, 103),
('Haa Alif Atoll', '07', 'Dhidhdhoo', 63, 103),
('Haa Dhaalu Atoll', '23', 'Kulhudhuffushi', 63, 103),
('Kaafu Atoll', '26', 'Thulusdhoo', 63, 103),
('Laamu Atoll', '05', 'Fonadhoo', 63, 103),
('Lhaviyani Atoll', '03', 'Naifaru', 63, 103),
('Malé', 'MLE', 'Malé', 63, 103),
('Meemu Atoll', '12', 'Muli', 63, 103),
('Noonu Atoll', '25', 'Manadhoo', 63, 103),
('Raa Atoll', '13', 'Ugoofaaru', 63, 103),
('Shaviyani Atoll', '24', 'Funadhoo', 63, 103),
('Thaa Atoll', '08', 'Veymandoo', 63, 103),
('Vaavu Atoll', '04', 'Felidhoo', 63, 103),

-- Mali Regions (Country ID: 104, Timezone ID: 1 'Africa/Abidjan')
('Bamako', 'BKO', 'Bamako', 1, 104),
('Gao', '7', 'Gao', 1, 104),
('Kayes', '1', 'Kayes', 1, 104),
('Kidal', '8', 'Kidal', 1, 104),
('Koulikoro', '2', 'Koulikoro', 1, 104),
('Ménaka', '9', 'Ménaka', 1, 104),
('Mopti', '5', 'Mopti', 1, 104),
('Ségou', '4', 'Ségou', 1, 104),
('Sikasso', '3', 'Sikasso', 1, 104),
('Taoudénit', '10', 'Taoudénit', 1, 104),
('Tombouctou', '6', 'Timbuktu', 1, 104),

-- Malta Regions (Country ID: 105, Timezone ID: 114 'Europe/Berlin')
('Central Region', 'MRC', 'San Ġwann', 114, 105),
('Gozo Region', 'MRG', 'Victoria', 114, 105),
('Northern Region', 'MRN', 'St. Paul''s Bay', 114, 105),
('South Eastern Region', 'MRS', 'Tarxien', 114, 105),
('Southern Region', 'MRX', 'Qormi', 114, 105),

-- Marshall Islands Municipalities (Country ID: 106, Timezone ID: 62 'Asia/Anadyr')
('Ralik Chain', 'L', 'Jabat Island', 62, 106),
('Ratak Chain', 'T', 'Majuro', 62, 106),

-- Mauritania Regions (Country ID: 107, Timezone ID: 1 'Africa/Abidjan')
('Adrar', '07', 'Atar', 1, 107),
('Assaba', '03', 'Kiffa', 1, 107),
('Brakna', '05', 'Aleg', 1, 107),
('Dakhlet Nouadhibou', '08', 'Nouadhibou', 1, 107),
('Gorgol', '04', 'Kaédi', 1, 107),
('Guidimaka', '10', 'Sélibaby', 1, 107),
('Hodh Ech Chargui', '01', 'Néma', 1, 107),
('Hodh El Gharbi', '02', 'Ayoun el Atrous', 1, 107),
('Inchiri', '12', 'Akjoujt', 1, 107),
('Nouakchott-Nord', '14', 'Dar-Naim', 1, 107),
('Nouakchott-Ouest', '13', 'Tevragh-Zeina', 1, 107),
('Nouakchott-Sud', '15', 'Arafat', 1, 107),
('Tagant', '09', 'Tidjikja', 1, 107),
('Tiris Zemmour', '11', 'Zouérat', 1, 107),
('Trarza', '06', 'Rosso', 1, 107),

-- Mauritius Districts (Country ID: 108, Timezone ID: 70 'Asia/Dubai')
('Agalega Islands', 'AG', 'Vingt Cinq', 70, 108),
('Black River', 'BL', 'Bambous', 70, 108),
('Cargados Carajos Shoals', 'CC', 'Raphael', 70, 108),
('Flacq', 'FL', 'Centre de Flacq', 70, 108),
('Grand Port', 'GP', 'Mahébourg', 70, 108),
('Moka', 'MO', 'Quartier Militaire', 70, 108),
('Pamplemousses', 'PA', 'Triolet', 70, 108),
('Plaines Wilhems', 'PW', 'Rose Hill', 70, 108),
('Port Louis', 'PL', 'Port Louis', 70, 108),
('Rivière du Rempart', 'RR', 'Mapou', 70, 108),
('Rodrigues', 'RO', 'Port Mathurin', 70, 108),
('Savanne', 'SA', 'Souillac', 70, 108),

-- Mexico States (Country ID: 109, Timezone ID: 39 'America/Mexico_City')
('Aguascalientes', 'AGU', 'Aguascalientes', 39, 109),
('Baja California', 'BCN', 'Mexicali', 39, 109),
('Baja California Sur', 'BCS', 'La Paz', 39, 109),
('Campeche', 'CAM', 'San Francisco de Campeche', 39, 109),
('Chiapas', 'CHP', 'Tuxtla Gutiérrez', 39, 109),
('Chihuahua', 'CHH', 'Chihuahua', 39, 109),
('Coahuila', 'COA', 'Saltillo', 39, 109),
('Colima', 'COL', 'Colima', 39, 109),
('Durango', 'DUR', 'Victoria de Durango', 39, 109),
('Guanajuato', 'GUA', 'Guanajuato', 39, 109),
('Guerrero', 'GRO', 'Chilpancingo de los Bravo', 39, 109),
('Hidalgo', 'HID', 'Pachuca de Soto', 39, 109),
('Jalisco', 'JAL', 'Guadalajara', 39, 109),
('México', 'MEX', 'Toluca de Lerdo', 39, 109),
('Mexico City', 'CMX', 'Mexico City', 39, 109),
('Michoacán', 'MIC', 'Morelia', 39, 109),
('Morelos', 'MOR', 'Cuernavaca', 39, 109),
('Nayarit', 'NAY', 'Tepic', 39, 109),
('Nuevo León', 'NLE', 'Monterrey', 39, 109),
('Oaxaca', 'OAX', 'Oaxaca de Juárez', 39, 109),
('Puebla', 'PUE', 'Puebla de Zaragoza', 39, 109),
('Querétaro', 'QUE', 'Santiago de Querétaro', 39, 109),
('Quintana Roo', 'ROO', 'Chetumal', 39, 109),
('San Luis Potosí', 'SLP', 'San Luis Potosí', 39, 109),
('Sinaloa', 'SIN', 'Culiacán Rosales', 39, 109),
('Sonora', 'SON', 'Hermosillo', 39, 109),
('Tabasco', 'TAB', 'Villahermosa', 39, 109),
('Tamaulipas', 'TAM', 'Ciudad Victoria', 39, 109),
('Tlaxcala', 'TLA', 'Tlaxcala de Xicohténcatl', 39, 109),
('Veracruz', 'VER', 'Xalapa-Enríquez', 39, 109),
('Yucatán', 'YUC', 'Mérida', 39, 109),
('Zacatecas', 'ZAC', 'Zacatecas', 39, 109),

-- Micronesia States (Country ID: 110, Timezone ID: 144 'Pacific/Port_Moresby')
('Chuuk', 'TRK', 'Weno', 144, 110),
('Kosrae', 'KSA', 'Tofol', 144, 110),
('Pohnpei', 'PNI', 'Palikir', 144, 110),
('Yap', 'YAP', 'Colonia', 144, 110),

-- Moldova Administrative-Territorial Units (Country ID: 111, Timezone ID: 116 'Europe/Bucharest')
('Anenii Noi', 'AN', 'Anenii Noi', 116, 111),
('Basarabeasca', 'BS', 'Basarabeasca', 116, 111),
('Briceni', 'BR', 'Briceni', 116, 111),
('Cahul', 'CA', 'Cahul', 116, 111),
('Cantemir', 'CT', 'Cantemir', 116, 111),
('Călărași', 'CL', 'Călărași', 116, 111),
('Căușeni', 'CS', 'Căușeni', 116, 111),
('Chișinău', 'CU', 'Chișinău', 116, 111),
('Cimișlia', 'CM', 'Cimișlia', 116, 111),
('Criuleni', 'CR', 'Criuleni', 116, 111),
('Dondușeni', 'DO', 'Dondușeni', 116, 111),
('Drochia', 'DR', 'Drochia', 116, 111),
('Dubăsari', 'DU', 'Cocieri', 116, 111),
('Edineț', 'ED', 'Edineț', 116, 111),
('Fălești', 'FA', 'Fălești', 116, 111),
('Florești', 'FL', 'Florești', 116, 111),
('Gagauzia', 'GA', 'Comrat', 116, 111),
('Glodeni', 'GL', 'Glodeni', 116, 111),
('Hîncești', 'HI', 'Hîncești', 116, 111),
('Ialoveni', 'IA', 'Ialoveni', 116, 111),
('Leova', 'LE', 'Leova', 116, 111),
('Nisporeni', 'NI', 'Nisporeni', 116, 111),
('Ocnița', 'OC', 'Ocnița', 116, 111),
('Orhei', 'OR', 'Orhei', 116, 111),
('Rezina', 'RE', 'Rezina', 116, 111),
('Rîșcani', 'RI', 'Rîșcani', 116, 111),
('Sîngerei', 'SI', 'Sîngerei', 116, 111),
('Soroca', 'SO', 'Soroca', 116, 111),
('Strășeni', 'ST', 'Strășeni', 116, 111),
('Șoldănești', 'SD', 'Șoldănești', 116, 111),
('Ștefan Vodă', 'SV', 'Ștefan Vodă', 116, 111),
('Taraclia', 'TA', 'Taraclia', 116, 111),
('Telenești', 'TE', 'Telenești', 116, 111),
('Transnistria', 'SN', 'Tiraspol', 116, 111),
('Ungheni', 'UN', 'Ungheni', 116, 111),

-- Monaco (Country ID: 112, Timezone ID: 127 'Europe/Paris')
('Monaco', 'MC', 'Monaco', 127, 112),

-- Mongolia Provinces (Country ID: 113, Timezone ID: 88 'Asia/Shanghai')
('Arkhangai', '073', 'Tsetserleg', 88, 113),
('Bayan-Ölgii', '071', 'Ölgii', 88, 113),
('Bayankhongor', '069', 'Bayankhongor', 88, 113),
('Bulgan', '067', 'Bulgan', 88, 113),
('Darkhan-Uul', '037', 'Darkhan', 88, 113),
('Dornod', '061', 'Choibalsan', 88, 113),
('Dornogovi', '063', 'Sainshand', 88, 113),
('Dundgovi', '059', 'Mandalgovi', 88, 113),
('Govi-Altai', '065', 'Altai', 88, 113),
('Govisümber', '064', 'Choir', 88, 113),
('Khentii', '039', 'Öndörkhaan', 88, 113),
('Khovd', '043', 'Khovd', 88, 113),
('Khövsgöl', '041', 'Mörön', 88, 113),
('Ömnögovi', '053', 'Dalanzadgad', 88, 113),
('Orkhon', '035', 'Erdenet', 88, 113),
('Övörkhangai', '055', 'Arvaikheer', 88, 113),
('Selenge', '049', 'Sükhbaatar', 88, 113),
('Sükhbaatar', '051', 'Baruun-Urt', 88, 113),
('Töv', '047', 'Zuunmod', 88, 113),
('Uvs', '046', 'Ulaangom', 88, 113),
('Zavkhan', '057', 'Uliastai', 88, 113),
('Ulaanbaatar', '1', 'Ulaanbaatar', 88, 113),

-- Montenegro Municipalities (Country ID: 114, Timezone ID: 114 'Europe/Berlin')
('Andrijevica', '01', 'Andrijevica', 114, 114),
('Bar', '02', 'Bar', 114, 114),
('Berane', '03', 'Berane', 114, 114),
('Bijelo Polje', '04', 'Bijelo Polje', 114, 114),
('Budva', '05', 'Budva', 114, 114),
('Cetinje', '06', 'Cetinje', 114, 114),
('Danilovgrad', '07', 'Danilovgrad', 114, 114),
('Gusinje', '22', 'Gusinje', 114, 114),
('Herceg Novi', '08', 'Herceg Novi', 114, 114),
('Kolašin', '09', 'Kolašin', 114, 114),
('Kotor', '10', 'Kotor', 114, 114),
('Mojkovac', '11', 'Mojkovac', 114, 114),
('Nikšić', '12', 'Nikšić', 114, 114),
('Petnjica', '23', 'Petnjica', 114, 114),
('Plav', '13', 'Plav', 114, 114),
('Plužine', '14', 'Plužine', 114, 114),
('Pljevlja', '15', 'Pljevlja', 114, 114),
('Podgorica', '16', 'Podgorica', 114, 114),
('Rožaje', '17', 'Rožaje', 114, 114),
('Šavnik', '18', 'Šavnik', 114, 114),
('Tivat', '19', 'Tivat', 114, 114),
('Tuzi', '24', 'Tuzi', 114, 114),
('Ulcinj', '20', 'Ulcinj', 114, 114),
('Žabljak', '21', 'Žabljak', 114, 114),

-- Morocco Regions (Country ID: 115, Timezone ID: 6 'Africa/Casablanca')
('Béni Mellal-Khénifra', '05', 'Béni Mellal', 6, 115),
('Casablanca-Settat', '06', 'Casablanca', 6, 115),
('Drâa-Tafilalet', '08', 'Errachidia', 6, 115),
('Dakhla-Oued Ed-Dahab', '12', 'Dakhla', 6, 115),
('Fès-Meknès', '03', 'Fès', 6, 115),
('Guelmim-Oued Noun', '10', 'Guelmim', 6, 115),
('Laâyoune-Sakia El Hamra', '11', 'Laâyoune', 6, 115),
('Marrakesh-Safi', '07', 'Marrakesh', 6, 115),
('Oriental', '02', 'Oujda', 6, 115),
('Rabat-Salé-Kénitra', '04', 'Rabat', 6, 115),
('Souss-Massa', '09', 'Agadir', 6, 115),
('Tanger-Tétouan-Al Hoceïma', '01', 'Tanger', 6, 115),

-- Mozambique Provinces (Country ID: 116, Timezone ID: 13 'Africa/Maputo')
('Cabo Delgado', 'P', 'Pemba', 13, 116),
('Gaza', 'G', 'Xai-Xai', 13, 116),
('Inhambane', 'I', 'Inhambane', 13, 116),
('Manica', 'B', 'Chimoio', 13, 116),
('Maputo', 'L', 'Matola', 13, 116),
('Maputo City', 'MPM', 'Maputo', 13, 116),
('Nampula', 'N', 'Nampula', 13, 116),
('Niassa', 'A', 'Lichinga', 13, 116),
('Sofala', 'S', 'Beira', 13, 116),
('Tete', 'T', 'Tete', 13, 116),
('Zambezia', 'Q', 'Quelimane', 13, 116),

-- Myanmar Regions and States (Country ID: 117, Timezone ID: 69 'Asia/Colombo')
('Ayeyarwady', '07', 'Pathein', 69, 117),
('Bago', '02', 'Bago', 69, 117),
('Chin', '14', 'Hakha', 69, 117),
('Kachin', '11', 'Myitkyina', 69, 117),
('Kayah', '12', 'Loikaw', 69, 117),
('Kayin', '13', 'Hpa-An', 69, 117),
('Magway', '03', 'Magwe', 69, 117),
('Mandalay', '04', 'Mandalay', 69, 117),
('Mon', '15', 'Mawlamyine', 69, 117),
('Naypyidaw Union Territory', '18', 'Naypyidaw', 69, 117),
('Rakhine', '16', 'Sittwe', 69, 117),
('Sagaing', '01', 'Monywa', 69, 117),
('Shan', '17', 'Taunggyi', 69, 117),
('Tanintharyi', '05', 'Dawei', 69, 117),
('Yangon', '06', 'Yangon', 69, 117),

-- Namibia Regions (Country ID: 118, Timezone ID: 20 'Africa/Windhoek')
('Erongo', 'ER', 'Swakopmund', 20, 118),
('Hardap', 'HA', 'Mariental', 20, 118),
('Karas', 'KA', 'Keetmanshoop', 20, 118),
('Kavango East', 'KE', 'Rundu', 20, 118),
('Kavango West', 'KW', 'Nkurenkuru', 20, 118),
('Khomas', 'KH', 'Windhoek', 20, 118),
('Kunene', 'KU', 'Opuwo', 20, 118),
('Ohangwena', 'OW', 'Eenhana', 20, 118),
('Omaheke', 'OH', 'Gobabis', 20, 118),
('Omusati', 'OS', 'Outapi', 20, 118),
('Oshana', 'ON', 'Oshakati', 20, 118),
('Oshikoto', 'OT', 'Omuthiya', 20, 118),
('Otjozondjupa', 'OD', 'Otjiwarongo', 20, 118),
('Zambezi', 'CA', 'Katima Mulilo', 20, 118),

-- Nauru Districts (Country ID: 119, Timezone ID: 62 'Asia/Anadyr')
('Yaren', '14', 'Yaren', 62, 119),

-- Nepal Provinces (Country ID: 120, Timezone ID: 79 'Asia/Kathmandu')
('Province No. 1', 'P1', 'Biratnagar', 79, 120),
('Province No. 2', 'P2', 'Janakpur', 79, 120),
('Bagmati', 'P3', 'Hetauda', 79, 120),
('Gandaki', 'P4', 'Pokhara', 79, 120),
('Lumbini', 'P5', 'Deukhuri', 79, 120),
('Karnali', 'P6', 'Birendranagar', 79, 120),
('Sudurpashchim', 'P7', 'Godawari', 79, 120),

-- Netherlands Provinces (Country ID: 121, Timezone ID: 112 'Europe/Amsterdam')
('Drenthe', 'DR', 'Assen', 112, 121),
('Flevoland', 'FL', 'Lelystad', 112, 121),
('Friesland', 'FR', 'Leeuwarden', 112, 121),
('Gelderland', 'GE', 'Arnhem', 112, 121),
('Groningen', 'GR', 'Groningen', 112, 121),
('Limburg', 'LI', 'Maastricht', 112, 121),
('North Brabant', 'NB', '''s-Hertogenbosch', 112, 121),
('North Holland', 'NH', 'Haarlem', 112, 121),
('Overijssel', 'OV', 'Zwolle', 112, 121),
('South Holland', 'ZH', 'The Hague', 112, 121),
('Utrecht', 'UT', 'Utrecht', 112, 121),
('Zeeland', 'ZE', 'Middelburg', 112, 121),

-- New Zealand Regions (Country ID: 122, Timezone ID: 136 'Pacific/Auckland')
('Auckland', 'AUK', 'Auckland', 136, 122),
('Bay of Plenty', 'BOP', 'Whakatane', 136, 122),
('Canterbury', 'CAN', 'Christchurch', 136, 122),
('Gisborne', 'GIS', 'Gisborne', 136, 122),
('Hawke''s Bay', 'HKB', 'Napier', 136, 122),
('Manawatu-Wanganui', 'MWT', 'Palmerston North', 136, 122),
('Marlborough', 'MBH', 'Blenheim', 136, 122),
('Nelson', 'NSN', 'Nelson', 136, 122),
('Northland', 'NTL', 'Whangarei', 136, 122),
('Otago', 'OTA', 'Dunedin', 136, 122),
('Southland', 'STL', 'Invercargill', 136, 122),
('Taranaki', 'TKI', 'New Plymouth', 136, 122),
('Tasman', 'TAS', 'Richmond', 136, 122),
('Waikato', 'WKO', 'Hamilton', 136, 122),
('Wellington', 'WGN', 'Wellington', 136, 122),
('West Coast', 'WTC', 'Greymouth', 136, 122),

-- Nicaragua Departments (Country ID: 123, Timezone ID: 31 'America/Costa_Rica')
('Boaco', 'BO', 'Boaco', 31, 123),
('Carazo', 'CA', 'Jinotepe', 31, 123),
('Chinandega', 'CI', 'Chinandega', 31, 123),
('Chontales', 'CO', 'Juigalpa', 31, 123),
('Estelí', 'ES', 'Estelí', 31, 123),
('Granada', 'GR', 'Granada', 31, 123),
('Jinotega', 'JI', 'Jinotega', 31, 123),
('León', 'LE', 'León', 31, 123),
('Madriz', 'MD', 'Somoto', 31, 123),
('Managua', 'MN', 'Managua', 31, 123),
('Masaya', 'MS', 'Masaya', 31, 123),
('Matagalpa', 'MT', 'Matagalpa', 31, 123),
('Nueva Segovia', 'NS', 'Ocotal', 31, 123),
('Río San Juan', 'SJ', 'San Carlos', 31, 123),
('Rivas', 'RI', 'Rivas', 31, 123),
('North Caribbean Coast', 'AN', 'Puerto Cabezas', 31, 123),
('South Caribbean Coast', 'AS', 'Bluefields', 31, 123),

-- Niger Regions (Country ID: 124, Timezone ID: 12 'Africa/Lagos')
('Agadez', '1', 'Agadez', 12, 124),
('Diffa', '2', 'Diffa', 12, 124),
('Dosso', '3', 'Dosso', 12, 124),
('Maradi', '4', 'Maradi', 12, 124),
('Niamey', '8', 'Niamey', 12, 124),
('Tahoua', '5', 'Tahoua', 12, 124),
('Tillabéri', '6', 'Tillabéri', 12, 124),
('Zinder', '7', 'Zinder', 12, 124),

-- North Korea Provinces (Country ID: 126, Timezone ID: 87 'Asia/Seoul')
('Chagang', '04', 'Kanggye', 87, 126),
('North Hamgyong', '09', 'Chongjin', 87, 126),
('South Hamgyong', '08', 'Hamhung', 87, 126),
('North Hwanghae', '06', 'Sariwon', 87, 126),
('South Hwanghae', '05', 'Haeju', 87, 126),
('Kangwon', '07', 'Wonsan', 87, 126),
('North Pyongan', '03', 'Sinuiju', 87, 126),
('South Pyongan', '02', 'Pyongsong', 87, 126),
('Rason', '13', 'Rason', 87, 126),
('Ryanggang', '10', 'Hyesan', 87, 126),
('Pyongyang', '01', 'Pyongyang', 87, 126),

-- North Macedonia Municipalities (Country ID: 127, Timezone ID: 114 'Europe/Berlin')
('Greater Skopje', '85', 'Skopje', 114, 127),

-- Norway Counties (Country ID: 128, Timezone ID: 114 'Europe/Berlin')
('Agder', '42', 'Kristiansand', 114, 128),
('Innlandet', '34', 'Hamar', 114, 128),
('Møre og Romsdal', '15', 'Molde', 114, 128),
('Nordland', '18', 'Bodø', 114, 128),
('Oslo', '03', 'Oslo', 114, 128),
('Rogaland', '11', 'Stavanger', 114, 128),
('Troms og Finnmark', '54', 'Tromsø', 114, 128),
('Trøndelag', '50', 'Steinkjer', 114, 128),
('Vestfold og Telemark', '38', 'Skien', 114, 128),
('Vestland', '46', 'Bergen', 114, 128),
('Viken', '30', 'Oslo', 114, 128),

-- Oman Governorates (Country ID: 129, Timezone ID: 70 'Asia/Dubai')
('Ad Dakhiliyah', 'DA', 'Nizwa', 70, 129),
('Ad Dhahirah', 'ZA', 'Ibri', 70, 129),
('Al Batinah North', 'BS', 'Sohar', 70, 129),
('Al Batinah South', 'BJ', 'Rustaq', 70, 129),
('Al Buraimi', 'BU', 'Al Buraimi', 70, 129),
('Al Wusta', 'WU', 'Haima', 70, 129),
('Ash Sharqiyah North', 'SS', 'Ibra', 70, 129),
('Ash Sharqiyah South', 'SJ', 'Sur', 70, 129),
('Dhofar', 'ZU', 'Salalah', 70, 129),
('Muscat', 'MA', 'Muscat', 70, 129),
('Musandam', 'MU', 'Khasab', 70, 129),

-- Pakistan Provinces and Territories (Country ID: 130, Timezone ID: 78 'Asia/Karachi')
('Azad Jammu and Kashmir', 'JK', 'Muzaffarabad', 78, 130),
('Balochistan', 'BA', 'Quetta', 78, 130),
('Gilgit-Baltistan', 'GB', 'Gilgit', 78, 130),
('Islamabad Capital Territory', 'IS', 'Islamabad', 78, 130),
('Khyber Pakhtunkhwa', 'KP', 'Peshawar', 78, 130),
('Punjab', 'PB', 'Lahore', 78, 130),
('Sindh', 'SD', 'Karachi', 78, 130),

-- Palau States (Country ID: 131, Timezone ID: 92 'Asia/Tokyo')
('Aimeliik', '002', 'Mongami', 92, 131),
('Airai', '004', 'Ngetkib', 92, 131),
('Angaur', '010', 'Ngaramasch', 92, 131),
('Hatohobei', '050', 'Hatohobei', 92, 131),
('Kayangel', '100', 'Kayangel', 92, 131),
('Koror', '150', 'Koror', 92, 131),
('Melekeok', '212', 'Melekeok', 92, 131),
('Ngaraard', '214', 'Ulimang', 92, 131),
('Ngarchelong', '218', 'Mengellang', 92, 131),
('Ngardmau', '222', 'Urdmang', 92, 131),
('Ngatpang', '224', 'Ngetkib', 92, 131),
('Ngchesar', '226', 'Ngersuul', 92, 131),
('Ngiwal', '227', 'Ngerkeai', 92, 131),
('Peleliu', '228', 'Kloulklubed', 92, 131),
('Sonsorol', '350', 'Dongosaru', 92, 131),

-- Panama Provinces (Country ID: 132, Timezone ID: 28 'America/Bogota')
('Bocas del Toro', '1', 'Bocas del Toro', 28, 132),
('Chiriquí', '4', 'David', 28, 132),
('Coclé', '2', 'Penonomé', 28, 132),
('Colón', '3', 'Colón', 28, 132),
('Darién', '5', 'La Palma', 28, 132),
('Emberá', 'EM', 'Unión Chocó', 28, 132),
('Guna Yala', 'KY', 'El Porvenir', 28, 132),
('Herrera', '6', 'Chitré', 28, 132),
('Los Santos', '7', 'Las Tablas', 28, 132),
('Ngäbe-Buglé', 'NB', 'Llano Tugrí', 28, 132),
('Panamá', '8', 'Panama City', 28, 132),
('Panamá Oeste', '10', 'La Chorrera', 28, 132),
('Veraguas', '9', 'Santiago', 28, 132),

-- Papua New Guinea Provinces (Country ID: 133, Timezone ID: 144 'Pacific/Port_Moresby')
('Bougainville', 'NSB', 'Buka', 144, 133),
('Central', 'CPM', 'Port Moresby', 144, 133),
('Chimbu', 'CPK', 'Kundiawa', 144, 133),
('East New Britain', 'EBR', 'Kokopo', 144, 133),
('East Sepik', 'ESW', 'Wewak', 144, 133),
('Eastern Highlands', 'EHG', 'Goroka', 144, 133),
('Enga', 'EPW', 'Wabag', 144, 133),
('Gulf', 'GPK', 'Kerema', 144, 133),
('Hela', 'HLA', 'Tari', 144, 133),
('Jiwaka', 'JWK', 'Minj', 144, 133),
('Madang', 'MPM', 'Madang', 144, 133),
('Manus', 'MRL', 'Lorengau', 144, 133),
('Milne Bay', 'MBA', 'Alotau', 144, 133),
('Morobe', 'MPL', 'Lae', 144, 133),
('National Capital District', 'NCD', 'Port Moresby', 144, 133),
('New Ireland', 'NIK', 'Kavieng', 144, 133),
('Oro', 'NPP', 'Popondetta', 144, 133),
('Sandaun', 'SAN', 'Vanimo', 144, 133),
('Southern Highlands', 'SHM', 'Mendi', 144, 133),
('West New Britain', 'WBK', 'Kimbe', 144, 133),
('Western', 'WPD', 'Daru', 144, 133),
('Western Highlands', 'WHM', 'Mount Hagen', 144, 133),

-- Paraguay Departments (Country ID: 134, Timezone ID: 26 'America/Asuncion')
('Alto Paraguay', '16', 'Fuerte Olimpo', 26, 134),
('Alto Paraná', '10', 'Ciudad del Este', 26, 134),
('Amambay', '13', 'Pedro Juan Caballero', 26, 134),
('Asunción', 'ASU', 'Asunción', 26, 134),
('Boquerón', '19', 'Filadelfia', 26, 134),
('Caaguazú', '5', 'Coronel Oviedo', 26, 134),
('Caazapá', '6', 'Caazapá', 26, 134),
('Canindeyú', '14', 'Salto del Guairá', 26, 134),
('Central', '11', 'Areguá', 26, 134),
('Concepción', '1', 'Concepción', 26, 134),
('Cordillera', '3', 'Caacupé', 26, 134),
('Guairá', '4', 'Villarrica', 26, 134),
('Itapúa', '7', 'Encarnación', 26, 134),
('Misiones', '8', 'San Juan Bautista', 26, 134),
('Ñeembucú', '12', 'Pilar', 26, 134),
('Paraguarí', '9', 'Paraguarí', 26, 134),
('Presidente Hayes', '15', 'Villa Hayes', 26, 134),
('San Pedro', '2', 'San Pedro de Ycuamandiyú', 26, 134),

-- Peru Regions (Country ID: 135, Timezone ID: 37 'America/Lima')
('Amazonas', 'AMA', 'Chachapoyas', 37, 135),
('Áncash', 'ANC', 'Huaraz', 37, 135),
('Apurímac', 'APU', 'Abancay', 37, 135),
('Arequipa', 'ARE', 'Arequipa', 37, 135),
('Ayacucho', 'AYA', 'Ayacucho', 37, 135),
('Cajamarca', 'CAJ', 'Cajamarca', 37, 135),
('Callao', 'CAL', 'Callao', 37, 135),
('Cusco', 'CUS', 'Cusco', 37, 135),
('Huancavelica', 'HUV', 'Huancavelica', 37, 135),
('Huánuco', 'HUC', 'Huánuco', 37, 135),
('Ica', 'ICA', 'Ica', 37, 135),
('Junín', 'JUN', 'Huancayo', 37, 135),
('La Libertad', 'LAL', 'Trujillo', 37, 135),
('Lambayeque', 'LAM', 'Chiclayo', 37, 135),
('Lima', 'LIM', 'Lima', 37, 135),
('Loreto', 'LOR', 'Iquitos', 37, 135),
('Madre de Dios', 'MDD', 'Puerto Maldonado', 37, 135),
('Moquegua', 'MOQ', 'Moquegua', 37, 135),
('Pasco', 'PAS', 'Cerro de Pasco', 37, 135),
('Piura', 'PIU', 'Piura', 37, 135),
('Puno', 'PUN', 'Puno', 37, 135),
('San Martín', 'SAM', 'Moyobamba', 37, 135),
('Tacna', 'TAC', 'Tacna', 37, 135),
('Tumbes', 'TUM', 'Tumbes', 37, 135),
('Ucayali', 'UCA', 'Pucallpa', 37, 135),

-- Philippines Regions (Country ID: 136, Timezone ID: 83 'Asia/Manila')
('Ilocos Region', '01', 'San Fernando', 83, 136),
('Cagayan Valley', '02', 'Tuguegarao', 83, 136),
('Central Luzon', '03', 'San Fernando', 83, 136),
('Calabarzon', '4A', 'Calamba', 83, 136),
('Mimaropa', '4B', 'Calapan', 83, 136),
('Bicol Region', '05', 'Legazpi', 83, 136),
('Western Visayas', '06', 'Iloilo City', 83, 136),
('Central Visayas', '07', 'Cebu City', 83, 136),
('Eastern Visayas', '08', 'Tacloban', 83, 136),
('Zamboanga Peninsula', '09', 'Pagadian', 83, 136),
('Northern Mindanao', '10', 'Cagayan de Oro', 83, 136),
('Davao Region', '11', 'Davao City', 83, 136),
('Soccsksargen', '12', 'Koronadal', 83, 136),
('National Capital Region', 'NCR', 'Manila', 83, 136),
('Cordillera Administrative Region', 'CAR', 'Baguio', 83, 136),
('Bangsamoro', '14', 'Cotabato City', 83, 136),
('Caraga', '13', 'Butuan', 83, 136),

-- Poland Voivodeships (Country ID: 137, Timezone ID: 134 'Europe/Warsaw')
('Greater Poland', 'WP', 'Poznań', 134, 137),
('Kuyavian-Pomeranian', 'KP', 'Bydgoszcz', 134, 137),
('Lesser Poland', 'MA', 'Kraków', 134, 137),
('Łódź', 'LD', 'Łódź', 134, 137),
('Lower Silesian', 'DS', 'Wrocław', 134, 137),
('Lublin', 'LU', 'Lublin', 134, 137),
('Lubusz', 'LB', 'Gorzów Wielkopolski', 134, 137),
('Masovian', 'MZ', 'Warsaw', 134, 137),
('Opole', 'OP', 'Opole', 134, 137),
('Podkarpackie', 'PK', 'Rzeszów', 134, 137),
('Podlaskie', 'PD', 'Białystok', 134, 137),
('Pomeranian', 'PM', 'Gdańsk', 134, 137),
('Silesian', 'SL', 'Katowice', 134, 137),
('Świętokrzyskie', 'SK', 'Kielce', 134, 137),
('Warmian-Masurian', 'WN', 'Olsztyn', 134, 137),
('West Pomeranian', 'ZP', 'Szczecin', 134, 137),

-- Portugal Districts (Country ID: 138, Timezone ID: 123 'Europe/Lisbon')
('Aveiro', '01', 'Aveiro', 123, 138),
('Azores', '20', 'Ponta Delgada', 123, 138),
('Beja', '02', 'Beja', 123, 138),
('Braga', '03', 'Braga', 123, 138),
('Bragança', '04', 'Bragança', 123, 138),
('Castelo Branco', '05', 'Castelo Branco', 123, 138),
('Coimbra', '06', 'Coimbra', 123, 138),
('Évora', '07', 'Évora', 123, 138),
('Faro', '08', 'Faro', 123, 138),
('Guarda', '09', 'Guarda', 123, 138),
('Leiria', '10', 'Leiria', 123, 138),
('Lisbon', '11', 'Lisbon', 123, 138),
('Madeira', '30', 'Funchal', 123, 138),
('Portalegre', '12', 'Portalegre', 123, 138),
('Porto', '13', 'Porto', 123, 138),
('Santarém', '14', 'Santarém', 123, 138),
('Setúbal', '15', 'Setúbal', 123, 138),
('Viana do Castelo', '16', 'Viana do Castelo', 123, 138),
('Vila Real', '17', 'Vila Real', 123, 138),
('Viseu', '18', 'Viseu', 123, 138),

-- Qatar Municipalities (Country ID: 139, Timezone ID: 86 'Asia/Qatar')
('Al Daayen', 'ZA', 'Al Daayen', 86, 139),
('Al Khor', 'KH', 'Al Khor', 86, 139),
('Al Rayyan', 'RA', 'Al Rayyan', 86, 139),
('Al Wakrah', 'WA', 'Al Wakrah', 86, 139),
('Al-Shahaniya', 'SH', 'Al-Shahaniya', 86, 139),
('Doha', 'DA', 'Doha', 86, 139),
('Madinat ash Shamal', 'MS', 'Madinat ash Shamal', 86, 139),
('Umm Salal', 'US', 'Umm Salal Mohammed', 86, 139),

-- Romania Counties (Country ID: 140, Timezone ID: 116 'Europe/Bucharest')
('Alba', 'AB', 'Alba Iulia', 116, 140),
('Arad', 'AR', 'Arad', 116, 140),
('Argeș', 'AG', 'Pitești', 116, 140),
('Bacău', 'BC', 'Bacău', 116, 140),
('Bihor', 'BH', 'Oradea', 116, 140),
('Bistrița-Năsăud', 'BN', 'Bistrița', 116, 140),
('Botoșani', 'BT', 'Botoșani', 116, 140),
('Brașov', 'BV', 'Brașov', 116, 140),
('Brăila', 'BR', 'Brăila', 116, 140),
('Bucharest', 'B', 'Bucharest', 116, 140),
('Buzău', 'BZ', 'Buzău', 116, 140),
('Caraș-Severin', 'CS', 'Reșița', 116, 140),
('Călărași', 'CL', 'Călărași', 116, 140),
('Cluj', 'CJ', 'Cluj-Napoca', 116, 140),
('Constanța', 'CT', 'Constanța', 116, 140),
('Covasna', 'CV', 'Sfântu Gheorghe', 116, 140),
('Dâmbovița', 'DB', 'Târgoviște', 116, 140),
('Dolj', 'DJ', 'Craiova', 116, 140),
('Galați', 'GL', 'Galați', 116, 140),
('Giurgiu', 'GR', 'Giurgiu', 116, 140),
('Gorj', 'GJ', 'Târgu Jiu', 116, 140),
('Harghita', 'HR', 'Miercurea Ciuc', 116, 140),
('Hunedoara', 'HD', 'Deva', 116, 140),
('Ialomița', 'IL', 'Slobozia', 116, 140),
('Iași', 'IS', 'Iași', 116, 140),
('Ilfov', 'IF', 'Buftea', 116, 140),
('Maramureș', 'MM', 'Baia Mare', 116, 140),
('Mehedinți', 'MH', 'Drobeta-Turnu Severin', 116, 140),
('Mureș', 'MS', 'Târgu Mureș', 116, 140),
('Neamț', 'NT', 'Piatra Neamț', 116, 140),
('Olt', 'OT', 'Slatina', 116, 140),
('Prahova', 'PH', 'Ploiești', 116, 140),
('Satu Mare', 'SM', 'Satu Mare', 116, 140),
('Sălaj', 'SJ', 'Zalău', 116, 140),
('Sibiu', 'SB', 'Sibiu', 116, 140),
('Suceava', 'SV', 'Suceava', 116, 140),
('Teleorman', 'TR', 'Alexandria', 116, 140),
('Timiș', 'TM', 'Timișoara', 116, 140),
('Tulcea', 'TL', 'Tulcea', 116, 140),
('Vaslui', 'VS', 'Vaslui', 116, 140),
('Vâlcea', 'VL', 'Râmnicu Vâlcea', 116, 140),
('Vrancea', 'VN', 'Focșani', 116, 140),

-- Russia Federal subjects (Country ID: 141, Timezone ID: 126 'Europe/Moscow')
('Altai Krai', 'ALT', 'Barnaul', 126, 141),
('Altai Republic', 'AL', 'Gorno-Altaysk', 126, 141),
('Amur Oblast', 'AMU', 'Blagoveshchensk', 126, 141),
('Arkhangelsk Oblast', 'ARK', 'Arkhangelsk', 126, 141),
('Astrakhan Oblast', 'AST', 'Astrakhan', 126, 141),
('Belgorod Oblast', 'BEL', 'Belgorod', 126, 141),
('Bryansk Oblast', 'BRY', 'Bryansk', 126, 141),
('Chechen Republic', 'CE', 'Grozny', 126, 141),
('Chelyabinsk Oblast', 'CHE', 'Chelyabinsk', 126, 141),
('Chukotka Autonomous Okrug', 'CHU', 'Anadyr', 126, 141),
('Chuvash Republic', 'CU', 'Cheboksary', 126, 141),
('Irkutsk Oblast', 'IRK', 'Irkutsk', 126, 141),
('Ivanovo Oblast', 'IVA', 'Ivanovo', 126, 141),
('Jewish Autonomous Oblast', 'YEV', 'Birobidzhan', 126, 141),
('Kabardino-Balkarian Republic', 'KB', 'Nalchik', 126, 141),
('Kaliningrad Oblast', 'KGD', 'Kaliningrad', 126, 141),
('Kaluga Oblast', 'KLU', 'Kaluga', 126, 141),
('Kamchatka Krai', 'KAM', 'Petropavlovsk-Kamchatsky', 126, 141),
('Karachay-Cherkess Republic', 'KC', 'Cherkessk', 126, 141),
('Kemerovo Oblast', 'KEM', 'Kemerovo', 126, 141),
('Khabarovsk Krai', 'KHA', 'Khabarovsk', 126, 141),
('Khanty-Mansi Autonomous Okrug', 'KHM', 'Khanty-Mansiysk', 126, 141),
('Kirov Oblast', 'KIR', 'Kirov', 126, 141),
('Komi Republic', 'KO', 'Syktyvkar', 126, 141),
('Kostroma Oblast', 'KOS', 'Kostroma', 126, 141),
('Krasnodar Krai', 'KDA', 'Krasnodar', 126, 141),
('Krasnoyarsk Krai', 'KYA', 'Krasnoyarsk', 126, 141),
('Kurgan Oblast', 'KGN', 'Kurgan', 126, 141),
('Kursk Oblast', 'KRS', 'Kursk', 126, 141),
('Leningrad Oblast', 'LEN', 'Saint Petersburg', 126, 141),
('Lipetsk Oblast', 'LIP', 'Lipetsk', 126, 141),
('Magadan Oblast', 'MAG', 'Magadan', 126, 141),
('Mari El Republic', 'ME', 'Yoshkar-Ola', 126, 141),
('Moscow', 'MOW', 'Moscow', 126, 141),
('Moscow Oblast', 'MOS', 'Moscow', 126, 141),
('Murmansk Oblast', 'MUR', 'Murmansk', 126, 141),
('Nenets Autonomous Okrug', 'NEN', 'Naryan-Mar', 126, 141),
('Nizhny Novgorod Oblast', 'NIZ', 'Nizhny Novgorod', 126, 141),
('Novgorod Oblast', 'NGR', 'Veliky Novgorod', 126, 141),
('Novosibirsk Oblast', 'NVS', 'Novosibirsk', 126, 141),
('Omsk Oblast', 'OMS', 'Omsk', 126, 141),
('Orenburg Oblast', 'ORE', 'Orenburg', 126, 141),
('Oryol Oblast', 'ORL', 'Oryol', 126, 141),
('Penza Oblast', 'PNZ', 'Penza', 126, 141),
('Perm Krai', 'PER', 'Perm', 126, 141),
('Primorsky Krai', 'PRI', 'Vladivostok', 126, 141),
('Pskov Oblast', 'PSK', 'Pskov', 126, 141),
('Republic of Adygea', 'AD', 'Maykop', 126, 141),
('Republic of Bashkortostan', 'BA', 'Ufa', 126, 141),
('Republic of Buryatia', 'BU', 'Ulan-Ude', 126, 141),
('Republic of Dagestan', 'DA', 'Makhachkala', 126, 141),
('Republic of Ingushetia', 'IN', 'Magas', 126, 141),
('Republic of Kalmykia', 'KL', 'Elista', 126, 141),
('Republic of Karelia', 'KR', 'Petrozavodsk', 126, 141),
('Republic of Khakassia', 'KK', 'Abakan', 126, 141),
('Republic of Mordovia', 'MO', 'Saransk', 126, 141),
('Republic of North Ossetia-Alania', 'SE', 'Vladikavkaz', 126, 141),
('Republic of Tatarstan', 'TA', 'Kazan', 126, 141),
('Rostov Oblast', 'ROS', 'Rostov-on-Don', 126, 141),
('Ryazan Oblast', 'RYA', 'Ryazan', 126, 141),
('Saint Petersburg', 'SPE', 'Saint Petersburg', 126, 141),
('Sakha Republic', 'SA', 'Yakutsk', 126, 141),
('Sakhalin Oblast', 'SAK', 'Yuzhno-Sakhalinsk', 126, 141),
('Samara Oblast', 'SAM', 'Samara', 126, 141),
('Saratov Oblast', 'SAR', 'Saratov', 126, 141),
('Smolensk Oblast', 'SMO', 'Smolensk', 126, 141),
('Stavropol Krai', 'STA', 'Stavropol', 126, 141),
('Sverdlovsk Oblast', 'SVE', 'Yekaterinburg', 126, 141),
('Tambov Oblast', 'TAM', 'Tambov', 126, 141),
('Tomsk Oblast', 'TOM', 'Tomsk', 126, 141),
('Tula Oblast', 'TUL', 'Tula', 126, 141),
('Tuva Republic', 'TY', 'Kyzyl', 126, 141),
('Tver Oblast', 'TVE', 'Tver', 126, 141),
('Tyumen Oblast', 'TYU', 'Tyumen', 126, 141),
('Udmurt Republic', 'UD', 'Izhevsk', 126, 141),
('Ulyanovsk Oblast', 'ULY', 'Ulyanovsk', 126, 141),
('Vladimir Oblast', 'VLA', 'Vladimir', 126, 141),
('Volgograd Oblast', 'VGG', 'Volgograd', 126, 141),
('Vologda Oblast', 'VLG', 'Vologda', 126, 141),
('Voronezh Oblast', 'VOR', 'Voronezh', 126, 141),
('Yamalo-Nenets Autonomous Okrug', 'YAN', 'Salekhard', 126, 141),
('Yaroslavl Oblast', 'YAR', 'Yaroslavl', 126, 141),
('Zabaykalsky Krai', 'ZAB', 'Chita', 126, 141),

-- Rwanda Provinces (Country ID: 142, Timezone ID: 13 'Africa/Maputo')
('Eastern', '02', 'Rwamagana', 13, 142),
('Kigali', '01', 'Kigali', 13, 142),
('Northern', '03', 'Byumba', 13, 142),
('Southern', '05', 'Nyanza', 13, 142),
('Western', '04', 'Kibuye', 13, 142),

-- Saint Kitts and Nevis Parishes (Country ID: 143, Timezone ID: 45 'America/Port_of_Spain')
('Christ Church Nichola Town', '01', 'Nichola Town', 45, 143),
('Saint Anne Sandy Point', '02', 'Sandy Point Town', 45, 143),
('Saint George Basseterre', '03', 'Basseterre', 45, 143),
('Saint George Gingerland', '04', 'Market Shop', 45, 143),
('Saint James Windward', '05', 'Newcastle', 45, 143),
('Saint John Capisterre', '06', 'Dieppe Bay Town', 45, 143),
('Saint John Figtree', '07', 'Figtree', 45, 143),
('Saint Mary Cayon', '08', 'Cayon', 45, 143),
('Saint Paul Capisterre', '09', 'Saint Paul Capisterre', 45, 143),
('Saint Paul Charlestown', '10', 'Charlestown', 45, 143),
('Saint Peter Basseterre', '11', 'Monkey Hill', 45, 143),
('Saint Thomas Lowland', '12', 'Cotton Ground', 45, 143),
('Saint Thomas Middle Island', '13', 'Middle Island', 45, 143),
('Trinity Palmetto Point', '15', 'Palmetto Point', 45, 143),

-- Saint Lucia Quarters (Country ID: 144, Timezone ID: 45 'America/Port_of_Spain')
('Anse la Raye', '01', 'Anse la Raye', 45, 144),
('Canaries', '12', 'Canaries', 45, 144),
('Castries', '02', 'Castries', 45, 144),
('Choiseul', '03', 'Choiseul', 45, 144),
('Dennery', '05', 'Dennery', 45, 144),
('Gros Islet', '06', 'Gros Islet', 45, 144),
('Laborie', '07', 'Laborie', 45, 144),
('Micoud', '08', 'Micoud', 45, 144),
('Soufrière', '10', 'Soufrière', 45, 144),
('Vieux Fort', '11', 'Vieux Fort', 45, 144),

-- Saint Vincent and the Grenadines Parishes (Country ID: 145, Timezone ID: 45 'America/Port_of_Spain')
('Charlotte', '01', 'Georgetown', 45, 145),
('Grenadines', '06', 'Port Elizabeth', 45, 145),
('Saint Andrew', '02', 'Layou', 45, 145),
('Saint David', '03', 'Chateaubelair', 45, 145),
('Saint George', '04', 'Kingstown', 45, 145),
('Saint Patrick', '05', 'Barrouallie', 45, 145),

-- Samoa Districts (Country ID: 146, Timezone ID: 135 'Pacific/Apia')
('A''ana', 'AA', 'Leulumoega', 135, 146),
('Aiga-i-le-Tai', 'AL', 'Mulifanua', 135, 146),
('Atua', 'AT', 'Lufilufi', 135, 146),
('Fa''asaleleaga', 'FA', 'Safotulafai', 135, 146),
('Gaga''emauga', 'GE', 'Saleaula', 135, 146),
('Gaga''ifomauga', 'GI', 'Aopo', 135, 146),
('Palauli', 'PA', 'Vailoa', 135, 146),
('Satupa''itea', 'SA', 'Satupa''itea', 135, 146),
('Tuamasaga', 'TU', 'Afega', 135, 146),
('Va''a-o-Fonoti', 'VF', 'Samamea', 135, 146),
('Vaisigano', 'VS', 'Asau', 135, 146),

-- San Marino Municipalities (Country ID: 147, Timezone ID: 129 'Europe/Rome')
('Acquaviva', '01', 'Acquaviva', 129, 147),
('Borgo Maggiore', '06', 'Borgo Maggiore', 129, 147),
('Chiesanuova', '02', 'Chiesanuova', 129, 147),
('Domagnano', '03', 'Domagnano', 129, 147),
('Faetano', '04', 'Faetano', 129, 147),
('Fiorentino', '05', 'Fiorentino', 129, 147),
('Montegiardino', '08', 'Montegiardino', 129, 147),
('San Marino', '07', 'San Marino', 129, 147),
('Serravalle', '09', 'Serravalle', 129, 147),

-- Sao Tome and Principe Provinces (Country ID: 148, Timezone ID: 17 'Africa/Sao_Tome')
('Príncipe', 'P', 'Santo António', 17, 148),
('São Tomé', 'S', 'São Tomé', 17, 148),

-- Saudi Arabia Regions (Country ID: 149, Timezone ID: 87 'Asia/Riyadh')
('Al-Bahah', '11', 'Al-Baha', 87, 149),
('Al-Jawf', '12', 'Sakaka', 87, 149),
('Al-Madinah', '03', 'Medina', 87, 149),
('Al-Qassim', '05', 'Buraidah', 87, 149),
('Asir', '14', 'Abha', 87, 149),
('Eastern Province', '04', 'Dammam', 87, 149),
('Ha''il', '06', 'Ha''il', 87, 149),
('Jizan', '09', 'Jizan', 87, 149),
('Makkah', '02', 'Mecca', 87, 149),
('Najran', '10', 'Najran', 87, 149),
('Northern Borders', '08', 'Arar', 87, 149),
('Riyadh', '01', 'Riyadh', 87, 149),
('Tabuk', '07', 'Tabuk', 87, 149),

-- Senegal Regions (Country ID: 150, Timezone ID: 1 'Africa/Abidjan')
('Dakar', 'DK', 'Dakar', 1, 150),
('Diourbel', 'DB', 'Diourbel', 1, 150),
('Fatick', 'FK', 'Fatick', 1, 150),
('Kaffrine', 'KA', 'Kaffrine', 1, 150),
('Kaolack', 'KL', 'Kaolack', 1, 150),
('Kédougou', 'KE', 'Kédougou', 1, 150),
('Kolda', 'KD', 'Kolda', 1, 150),
('Louga', 'LG', 'Louga', 1, 150),
('Matam', 'MT', 'Matam', 1, 150),
('Saint-Louis', 'SL', 'Saint-Louis', 1, 150),
('Sédhiou', 'SE', 'Sédhiou', 1, 150),
('Tambacounda', 'TC', 'Tambacounda', 1, 150),
('Thiès', 'TH', 'Thiès', 1, 150),
('Ziguinchor', 'ZG', 'Ziguinchor', 1, 150),

-- Serbia Districts (Country ID: 151, Timezone ID: 114 'Europe/Berlin')
('Belgrade', '00', 'Belgrade', 114, 151),
('Bor', '14', 'Bor', 114, 151),
('Braničevo', '11', 'Požarevac', 114, 151),
('Jablanica', '23', 'Leskovac', 114, 151),
('Kolubara', '09', 'Valjevo', 114, 151),
('Mačva', '08', 'Šabac', 114, 151),
('Moravica', '17', 'Čačak', 114, 151),
('Nišava', '20', 'Niš', 114, 151),
('North Bačka', '01', 'Subotica', 114, 151),
('North Banat', '03', 'Kikinda', 114, 151),
('Pčinja', '24', 'Vranje', 114, 151),
('Pirot', '22', 'Pirot', 114, 151),
('Podunavlje', '10', 'Smederevo', 114, 151),
('Pomoravlje', '13', 'Jagodina', 114, 151),
('Rasina', '19', 'Kruševac', 114, 151),
('Raška', '18', 'Kraljevo', 114, 151),
('South Bačka', '06', 'Novi Sad', 114, 151),
('South Banat', '04', 'Pančevo', 114, 151),
('Srem', '07', 'Sremska Mitrovica', 114, 151),
('Šumadija', '12', 'Kragujevac', 114, 151),
('Toplica', '21', 'Prokuplje', 114, 151),
('Vojvodina', 'VO', 'Novi Sad', 114, 151),
('West Bačka', '05', 'Sombor', 114, 151),
('Zaječar', '15', 'Zaječar', 114, 151),
('Zlatibor', '16', 'Užice', 114, 151),

-- Seychelles Districts (Country ID: 152, Timezone ID: 70 'Asia/Dubai')
('Anse Aux Pins', '01', 'Anse Aux Pins', 70, 152),
('Anse Boileau', '02', 'Anse Boileau', 70, 152),
('Anse Etoile', '03', 'Anse Etoile', 70, 152),
('Anse Royale', '05', 'Anse Royale', 70, 152),
('Au Cap', '04', 'Au Cap', 70, 152),
('Baie Lazare', '06', 'Baie Lazare', 70, 152),
('Baie Sainte Anne', '07', 'Anse Volbert', 70, 152),
('Beau Vallon', '08', 'Beau Vallon', 70, 152),
('Bel Air', '09', 'Bel Air', 70, 152),
('Bel Ombre', '10', 'Bel Ombre', 70, 152),
('Cascade', '11', 'Cascade', 70, 152),
('Glacis', '12', 'Glacis', 70, 152),
('Grand''Anse Mahé', '13', 'Grand''Anse', 70, 152),
('Grand''Anse Praslin', '14', 'Grand''Anse', 70, 152),
('La Digue', '15', 'La Passe', 70, 152),
('La Rivière Anglaise', '16', 'English River', 70, 152),
('Les Mamelles', '24', 'Les Mamelles', 70, 152),
('Mont Buxton', '17', 'Mont Buxton', 70, 152),
('Mont Fleuri', '18', 'Mont Fleuri', 70, 152),
('Plaisance', '19', 'Plaisance', 70, 152),
('Pointe La Rue', '20', 'Pointe La Rue', 70, 152),
('Port Glaud', '21', 'Port Glaud', 70, 152),
('Roche Caiman', '25', 'Roche Caiman', 70, 152),
('Saint Louis', '22', 'Saint Louis', 70, 152),
('Takamaka', '23', 'Takamaka', 70, 152),

-- Sierra Leone Provinces (Country ID: 153, Timezone ID: 1 'Africa/Abidjan')
('Eastern', 'E', 'Kenema', 1, 153),
('Northern', 'N', 'Makeni', 1, 153),
('North West', 'NW', 'Port Loko', 1, 153),
('Southern', 'S', 'Bo', 1, 153),
('Western Area', 'W', 'Freetown', 1, 153),

-- Singapore (Country ID: 154, Timezone ID: 89 'Asia/Singapore')
('Singapore', 'SG', 'Singapore', 89, 154),

-- Slovakia Regions (Country ID: 155, Timezone ID: 114 'Europe/Berlin')
('Banská Bystrica', 'BC', 'Banská Bystrica', 114, 155),
('Bratislava', 'BL', 'Bratislava', 114, 155),
('Košice', 'KI', 'Košice', 114, 155),
('Nitra', 'NI', 'Nitra', 114, 155),
('Prešov', 'PV', 'Prešov', 114, 155),
('Trenčín', 'TC', 'Trenčín', 114, 155),
('Trnava', 'TA', 'Trnava', 114, 155),
('Žilina', 'ZI', 'Žilina', 114, 155),

-- Slovenia Statistical Regions (Country ID: 156, Timezone ID: 114 'Europe/Berlin')
('Mura', '08', 'Murska Sobota', 114, 156),
('Drava', '02', 'Maribor', 114, 156),
('Carinthia', '04', 'Slovenj Gradec', 114, 156),
('Savinja', '09', 'Celje', 114, 156),
('Central Sava', '10', 'Trbovlje', 114, 156),
('Lower Sava', '11', 'Krško', 114, 156),
('Southeast Slovenia', '12', 'Novo Mesto', 114, 156),
('Littoral-Inner Carniola', '06', 'Postojna', 114, 156),
('Central Slovenia', '07', 'Ljubljana', 114, 156),
('Upper Carniola', '03', 'Kranj', 114, 156),
('Gorizia', '01', 'Nova Gorica', 114, 156),
('Coastal-Karst', '05', 'Koper', 114, 156),

-- Solomon Islands Provinces (Country ID: 157, Timezone ID: 144 'Pacific/Port_Moresby')
('Central', 'CE', 'Tulagi', 144, 157),
('Choiseul', 'CH', 'Taro Island', 144, 157),
('Guadalcanal', 'GU', 'Honiara', 144, 157),
('Honiara', 'CT', 'Honiara', 144, 157),
('Isabel', 'IS', 'Buala', 144, 157),
('Makira-Ulawa', 'MK', 'Kirakira', 144, 157),
('Malaita', 'ML', 'Auki', 144, 157),
('Rennell and Bellona', 'RB', 'Tigoa', 144, 157),
('Temotu', 'TE', 'Lata', 144, 157),
('Western', 'WE', 'Gizo', 144, 157),

-- Somalia Federal Member States (Country ID: 158, Timezone ID: 15 'Africa/Nairobi')
('Banaadir', 'BN', 'Mogadishu', 15, 158),
('Galmudug', 'GA', 'Dhusamareb', 15, 158),
('Hirshabelle', 'HI', 'Jowhar', 15, 158),
('Jubaland', 'JU', 'Kismayo', 15, 158),
('Puntland', 'PL', 'Garowe', 15, 158),
('South West', 'SW', 'Barawa', 15, 158),

-- South Africa Provinces (Country ID: 159, Timezone ID: 9 'Africa/Johannesburg')
('Eastern Cape', 'EC', 'Bhisho', 9, 159),
('Free State', 'FS', 'Bloemfontein', 9, 159),
('Gauteng', 'GP', 'Johannesburg', 9, 159),
('KwaZulu-Natal', 'KZN', 'Pietermaritzburg', 9, 159),
('Limpopo', 'LP', 'Polokwane', 9, 159),
('Mpumalanga', 'MP', 'Mbombela', 9, 159),
('North West', 'NW', 'Mahikeng', 9, 159),
('Northern Cape', 'NC', 'Kimberley', 9, 159),
('Western Cape', 'WC', 'Cape Town', 9, 159),

-- South Korea Provinces (Country ID: 160, Timezone ID: 87 'Asia/Seoul')
('North Chungcheong', '43', 'Cheongju', 87, 160),
('South Chungcheong', '44', 'Hongseong', 87, 160),
('Gangwon', '42', 'Chuncheon', 87, 160),
('Gyeonggi', '41', 'Suwon', 87, 160),
('North Gyeongsang', '47', 'Andong', 87, 160),
('South Gyeongsang', '48', 'Changwon', 87, 160),
('North Jeolla', '45', 'Jeonju', 87, 160),
('South Jeolla', '46', 'Muan', 87, 160),
('Jeju', '49', 'Jeju', 87, 160),
('Seoul', '11', 'Seoul', 87, 160),
('Busan', '26', 'Busan', 87, 160),
('Daegu', '27', 'Daegu', 87, 160),
('Incheon', '28', 'Incheon', 87, 160),
('Gwangju', '29', 'Gwangju', 87, 160),
('Daejeon', '30', 'Daejeon', 87, 160),
('Ulsan', '31', 'Ulsan', 87, 160),
('Sejong', '50', 'Sejong', 87, 160),

-- South Sudan States (Country ID: 161, Timezone ID: 10 'Africa/Juba')
('Central Equatoria', 'EC', 'Juba', 10, 161),
('Eastern Equatoria', 'EE', 'Torit', 10, 161),
('Jonglei', 'JG', 'Bor', 10, 161),
('Lakes', 'LK', 'Rumbek', 10, 161),
('Northern Bahr el Ghazal', 'BN', 'Aweil', 10, 161),
('Unity', 'UY', 'Bentiu', 10, 161),
('Upper Nile', 'NU', 'Malakal', 10, 161),
('Warrap', 'WR', 'Kuajok', 10, 161),
('Western Bahr el Ghazal', 'BW', 'Wau', 10, 161),
('Western Equatoria', 'EW', 'Yambio', 10, 161),

-- Spain Autonomous communities (Country ID: 162, Timezone ID: 125 'Europe/Madrid')
('Andalusia', 'AN', 'Seville', 125, 162),
('Aragon', 'AR', 'Zaragoza', 125, 162),
('Asturias', 'AS', 'Oviedo', 125, 162),
('Balearic Islands', 'IB', 'Palma', 125, 162),
('Basque Country', 'PV', 'Vitoria-Gasteiz', 125, 162),
('Canary Islands', 'CN', 'Santa Cruz de Tenerife', 125, 162),
('Cantabria', 'CB', 'Santander', 125, 162),
('Castile and León', 'CL', 'Valladolid', 125, 162),
('Castilla-La Mancha', 'CM', 'Toledo', 125, 162),
('Catalonia', 'CT', 'Barcelona', 125, 162),
('Ceuta', 'CE', 'Ceuta', 125, 162),
('Extremadura', 'EX', 'Mérida', 125, 162),
('Galicia', 'GA', 'Santiago de Compostela', 125, 162),
('La Rioja', 'RI', 'Logroño', 125, 162),
('Madrid', 'MD', 'Madrid', 125, 162),
('Melilla', 'ML', 'Melilla', 125, 162),
('Murcia', 'MC', 'Murcia', 125, 162),
('Navarre', 'NC', 'Pamplona', 125, 162),
('Valencian Community', 'VC', 'Valencia', 125, 162),

-- Sri Lanka Provinces (Country ID: 163, Timezone ID: 69 'Asia/Colombo')
('Central', '2', 'Kandy', 69, 163),
('Eastern', '5', 'Trincomalee', 69, 163),
('North Central', '7', 'Anuradhapura', 69, 163),
('Northern', '4', 'Jaffna', 69, 163),
('North Western', '6', 'Kurunegala', 69, 163),
('Sabaragamuwa', '9', 'Ratnapura', 69, 163),
('Southern', '3', 'Galle', 69, 163),
('Uva', '8', 'Badulla', 69, 163),
('Western', '1', 'Colombo', 69, 163),

-- Sudan States (Country ID: 164, Timezone ID: 11 'Africa/Khartoum')
('Blue Nile', 'NB', 'Ad-Damazin', 11, 164),
('Central Darfur', 'DC', 'Zalingei', 11, 164),
('East Darfur', 'DE', 'Ed Daein', 11, 164),
('Gezira', 'GZ', 'Wad Madani', 11, 164),
('Kassala', 'KA', 'Kassala', 11, 164),
('Khartoum', 'KH', 'Khartoum', 11, 164),
('North Darfur', 'DN', 'Al-Fashir', 11, 164),
('North Kordofan', 'KN', 'Al-Ubayyid', 11, 164),
('Northern', 'NO', 'Dongola', 11, 164),
('Red Sea', 'RS', 'Port Sudan', 11, 164),
('River Nile', 'NR', 'Ad-Damir', 11, 164),
('Sennar', 'SI', 'Singa', 11, 164),
('South Darfur', 'DS', 'Nyala', 11, 164),
('South Kordofan', 'KS', 'Kadugli', 11, 164),
('West Darfur', 'DW', 'Geneina', 11, 164),
('West Kordofan', 'GK', 'Al-Fulah', 11, 164),
('White Nile', 'NW', 'Rabak', 11, 164),

-- Suriname Districts (Country ID: 165, Timezone ID: 24 'America/Argentina/Buenos_Aires')
('Brokopondo', 'BR', 'Brokopondo', 24, 165),
('Commewijne', 'CM', 'Nieuw-Amsterdam', 24, 165),
('Coronie', 'CR', 'Totness', 24, 165),
('Marowijne', 'MA', 'Albina', 24, 165),
('Nickerie', 'NI', 'Nieuw-Nickerie', 24, 165),
('Para', 'PR', 'Onverwacht', 24, 165),
('Paramaribo', 'PM', 'Paramaribo', 24, 165),
('Saramacca', 'SA', 'Groningen', 24, 165),
('Sipaliwini', 'SI', 'Paramaribo', 24, 165),
('Wanica', 'WA', 'Lelydorp', 24, 165),

-- Sweden Counties (Country ID: 166, Timezone ID: 132 'Europe/Stockholm')
('Blekinge', 'K', 'Karlskrona', 132, 166),
('Dalarna', 'W', 'Falun', 132, 166),
('Gävleborg', 'X', 'Gävle', 132, 166),
('Gotland', 'I', 'Visby', 132, 166),
('Halland', 'N', 'Halmstad', 132, 166),
('Jämtland', 'Z', 'Östersund', 132, 166),
('Jönköping', 'F', 'Jönköping', 132, 166),
('Kalmar', 'H',



-- Script: columns.sql

DELIMITER $$

CREATE PROCEDURE usp_CreateColumns_tblUserProfiles()
BEGIN
    DECLARE v_required BOOLEAN DEFAULT TRUE;
    DECLARE v_optional BOOLEAN DEFAULT FALSE;

    CALL usp_AddColumn('tblUserProfiles', 'phone_number', 'VARCHAR(15)', NULL, v_required);
    CALL usp_AddColumn('tblUserProfiles', 'gender', 'TINYINT', NULL, v_required);
    CALL usp_AddColumn('tblUserProfiles', 'date_of_birth', 'DATE', NULL, v_required);
    CALL usp_AddColumn('tblUserProfiles', 'address_line1', 'VARCHAR(255)', NULL, v_required);
    CALL usp_AddColumn('tblUserProfiles', 'address_line2', 'VARCHAR(255)', NULL, v_optional);
    CALL usp_AddColumn('tblUserProfiles', 'state_id', 'BIGINT UNSIGNED', NULL, v_required);
    CALL usp_AddColumn('tblUserProfiles', 'country_id', 'BIGINT UNSIGNED', NULL, v_required);
    CALL usp_AddColumn('tblUserProfiles', 'city', 'VARCHAR(255)', NULL, v_required);
    CALL usp_AddColumn('tblUserProfiles', 'postal_code', 'VARCHAR(20)', NULL, v_required);
    CALL usp_AddColumn('tblUserProfiles', 'avatar_url', 'VARCHAR(512)', NULL, v_optional);
    CALL usp_AddColumn('tblUserProfiles', 'user_id', 'BIGINT UNSIGNED', NULL, v_required);
END$$

DELIMITER ;

CALL usp_CreateColumns_tblUserProfiles();
DROP PROCEDURE usp_CreateColumns_tblUserProfiles;


-- Script: constraints.sql

CALL usp_CreateUniqueKey('tblUserProfiles', 'user_id');
CALL usp_AddCheck('tblUserProfiles', 'gender', 'gender IN (1, 2, 3)');
CALL usp_AddCheck('tblUserProfiles', 'date_of_birth', 'date_of_birth <= CURDATE()');
CALL usp_AddCheck('tblUserProfiles', 'phone_number', "TRIM(phone_number) <> ''");
CALL usp_AddCheck('tblUserProfiles', 'address_line1', "TRIM(address_line1) <> ''");
CALL usp_AddCheck('tblUserProfiles', 'city', "TRIM(city) <> ''");
CALL usp_AddCheck('tblUserProfiles', 'postal_code', "TRIM(postal_code) <> ''");


-- Script: foreignkeys.sql

CALL usp_CreateForeignKey('tblUserProfiles', 'user_id', 'tblUsers', 'id');
CALL usp_CreateForeignKey('tblUserProfiles', 'country_id', 'tblCountries', 'id');
CALL usp_CreateForeignKey('tblUserProfiles', 'state_id', 'tblStates', 'id');


-- Script: usp_RegisterUser.sql

DELIMITER $$
DROP PROCEDURE IF EXISTS usp_RegisterUser$$

CREATE PROCEDURE usp_RegisterUser(
    IN in_firstname VARCHAR(128),
    IN in_lastname VARCHAR(128),
    IN in_email VARCHAR(255),
    IN in_password VARCHAR(255),
    IN in_phone_number VARCHAR(15),
    IN in_gender TINYINT,
    IN in_date_of_birth DATE,
    IN in_address_line1 VARCHAR(255),
    IN in_address_line2 VARCHAR(255),
    IN in_country_id BIGINT UNSIGNED,
    IN in_region_id BIGINT UNSIGNED,
    IN in_city VARCHAR(255),
    IN in_postal_code VARCHAR(20),
    IN in_avatar_url VARCHAR(512)
)
proc_label:BEGIN
    DECLARE v_user_id BIGINT UNSIGNED;
    DECLARE v_record_exists INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF in_firstname IS NULL OR TRIM(in_firstname) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'First name is required.';
    END IF;
    IF in_lastname IS NULL OR TRIM(in_lastname) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Last name is required.';
    END IF;
    IF in_phone_number IS NULL OR TRIM(in_phone_number) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Phone number is required.';
    END IF;
    IF in_address_line1 IS NULL OR TRIM(in_address_line1) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Address line 1 is required.';
    END IF;
    IF in_city IS NULL OR TRIM(in_city) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'City is required.';
    END IF;
    IF in_postal_code IS NULL OR TRIM(in_postal_code) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Postal code is required.';
    END IF;

    IF in_email IS NULL OR NOT in_email REGEXP '^[a-zA-Z0-9][a-zA-Z0-9._-]*@[a-zA-Z0-9][a-zA-Z0-9._-]*\\.[a-zA-Z]{2,4}$' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A valid email address is required.';
    END IF;

    SELECT COUNT(1) INTO v_record_exists FROM tblUsers WHERE email = in_email;
    IF v_record_exists > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This email address is already registered.';
    END IF;

    IF in_password IS NULL OR NOT in_password REGEXP '^[a-f0-9]{64}$' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid password format. A SHA-256 hash is expected.';
    END IF;

    IF in_gender NOT IN (1, 2, 3) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid gender specified. Allowed values are 1, 2, 3.';
    END IF;

    IF in_date_of_birth IS NULL OR in_date_of_birth > CURDATE() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Date of birth cannot be in the future.';
    END IF;

    SELECT COUNT(1) INTO v_record_exists FROM tblCountries WHERE id = in_country_id;
    IF v_record_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The specified country does not exist.';
    END IF;

    SELECT COUNT(1) INTO v_record_exists FROM tblStates WHERE id = in_region_id AND country_id = in_country_id;
    IF v_record_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The specified region is not valid for the selected country.';
    END IF;

    START TRANSACTION;

    INSERT INTO tblUsers (firstname, lastname, email, `password`, created_by)
    VALUES (TRIM(in_firstname), TRIM(in_lastname), TRIM(in_email), in_password, 0);
    SET v_user_id = LAST_INSERT_ID();

    UPDATE tblUsers SET created_by = v_user_id WHERE id = v_user_id;

    INSERT INTO tblUserProfiles (
        user_id,
        phone_number,
        gender,
        date_of_birth,
        address_line1,
        address_line2,
        country_id,
        region_id,
        city,
        postal_code,
        avatar_url,
        created_by
    ) VALUES (
        v_user_id,
        TRIM(in_phone_number),
        in_gender,
        in_date_of_birth,
        TRIM(in_address_line1),
        IF(in_address_line2 IS NULL OR TRIM(in_address_line2) = '', NULL, TRIM(in_address_line2)),
        in_country_id,
        in_region_id,
        TRIM(in_city),
        TRIM(in_postal_code),
        IF(in_avatar_url IS NULL OR TRIM(in_avatar_url) = '', NULL, TRIM(in_avatar_url)),
        v_user_id
    );

    COMMIT;

    SELECT v_user_id AS new_user_id;

END$$

DELIMITER ;


-- Script: usp_GetUser.sql

DELIMITER $$
DROP PROCEDURE IF EXISTS usp_GetUser$$

CREATE PROCEDURE usp_GetUser(
    IN in_id BIGINT UNSIGNED,
    IN in_email VARCHAR(255)
)
proc_label:BEGIN

    IF in_id IS NULL AND (in_email IS NULL OR TRIM(in_email) = '') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Either a user ID or an email must be provided.';
        LEAVE proc_label;
    END IF;

    SELECT
        u.id,
        BIN_TO_UUID(u.internal_id) AS internal_id,
        u.firstname,
        u.lastname,
        u.email,
        u.created_at,
        u.updated_at,
        up.phone_number,
        up.gender,
        up.date_of_birth,
        up.address_line1,
        up.address_line2,
        up.city,
        up.postal_code,
        up.avatar_url,
        c.id AS country_id,
        c.name AS country_name,
        c.iso3_code AS country_iso3,
        s.id AS region_id,
        s.name AS region_name,
        s.iso_code AS region_iso
    FROM
        tblUsers u
    LEFT JOIN tblUserProfiles up ON u.id = up.user_id
    LEFT JOIN tblCountries c ON up.country_id = c.id
    LEFT JOIN tblStates s ON up.region_id = s.id
    WHERE (in_id IS NOT NULL AND u.id = in_id) OR (in_email IS NOT NULL AND u.email = in_email)
    LIMIT 1;

END$$

DELIMITER ;


-- Script: usp_GetCurrencies.sql

DELIMITER $$
DROP PROCEDURE IF EXISTS usp_GetCurrencies$$

CREATE PROCEDURE usp_GetCurrencies(
    IN in_id BIGINT UNSIGNED
)
BEGIN
    SELECT
        id,
        iso_code,
        numeric_code,
        name,
        symbol,
        minor_unit
    FROM tblCurrencies
    WHERE void = 0 AND (in_id IS NULL OR id = in_id)
    ORDER BY name;
END$$

DELIMITER ;


-- Script: usp_GetCountries.sql

DELIMITER $$
DROP PROCEDURE IF EXISTS usp_GetCountries$$

CREATE PROCEDURE usp_GetCountries(
    IN in_id BIGINT UNSIGNED
)
BEGIN
    SELECT
        c.id,
        c.iso2_code,
        c.iso3_code,
        c.numeric_code,
        c.name,
        c.official_name,
        c.capital,
        c.phone_code,
        cur.id AS currency_id,
        cur.name AS currency_name,
        cur.symbol AS currency_symbol
    FROM
        tblCountries c
    LEFT JOIN tblCurrencies cur ON c.currency_id = cur.id
    WHERE c.void = 0 AND (in_id IS NULL OR c.id = in_id)
    ORDER BY c.name;
END$$

DELIMITER ;


-- Script: usp_GetTimeZones.sql

DELIMITER $$
DROP PROCEDURE IF EXISTS usp_GetTimeZones$$

CREATE PROCEDURE usp_GetTimeZones(
    IN in_id BIGINT UNSIGNED
)
BEGIN
    SELECT
        id,
        name,
        abbreviation,
        utc_offset_minutes,
        observes_dst,
        current_offset_minutes
    FROM tblTimeZones
    WHERE (in_id IS NULL OR id = in_id)
    ORDER BY utc_offset_minutes, name;
END$$

DELIMITER ;


-- Script: usp_GetStates.sql

DELIMITER $
DROP PROCEDURE IF EXISTS usp_GetStates$

CREATE PROCEDURE usp_GetStates(
    IN in_id BIGINT UNSIGNED,
    IN in_country_id BIGINT UNSIGNED
)
BEGIN
    SELECT
        s.id,
        s.name,
        s.official_name,
        s.iso_code,
        s.capital,
        s.phone_code,
        s.country_id,
        c.name AS country_name,
        s.timezone_id,
        tz.name AS timezone_name
    FROM tblStates s
    LEFT JOIN tblCountries c ON s.country_id = c.id
    LEFT JOIN tblTimeZones tz ON s.timezone_id = tz.id
    WHERE s.void = 0 AND (in_id IS NULL OR s.id = in_id)
    AND (in_country_id IS NULL OR s.country_id = in_country_id)
    ORDER BY c.name, s.name;
END$

DELIMITER ;


