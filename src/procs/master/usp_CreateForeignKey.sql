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

SELECT 'usp_CreateForeignKey created successfully.' AS message;