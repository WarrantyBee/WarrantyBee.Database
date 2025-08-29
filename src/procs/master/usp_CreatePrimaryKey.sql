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
