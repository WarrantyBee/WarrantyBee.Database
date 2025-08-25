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
--   in_constraint_name   - The name to assign to the FOREIGN KEY constraint.
--
-- Usage:
--   CALL usp_CreateForeignKey(
--       'tblBooks',
--       'category_id',
--       'tblCategories',
--       'id',
--       'fk_tblCategories_tblBooks.category_id'
--   );
--
-- Notes:
--   - The procedure checks if a foreign key already exists on the specified column before adding one.
--   - If no foreign key exists, it uses dynamic SQL to add the specified FOREIGN KEY constraint.
--   - The constraint will be created with the provided name, referencing the specified table and column.
--   - Checks for table and column existence before attempting to add the constraint.
--   - Prints messages for every execution flow and handles exceptions.
-- =============================================

CREATE PROCEDURE usp_CreateForeignKey(
    IN in_table_name VARCHAR(64),
    IN in_column_name VARCHAR(64),
    IN in_ref_table_name VARCHAR(64),
    IN in_ref_column_name VARCHAR(64),
    IN in_constraint_name VARCHAR(64)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT CONCAT(
            'Foreign key ',
            in_constraint_name,
            ' creation failed due to an exception.'
        ) AS message;
    END;

    IF NOT ufn_DoesTableExist(in_table_name) THEN
        SELECT CONCAT(
            'Foreign key ',
            in_constraint_name,
            ' creation failed due to table ',
            in_table_name,
            ' does not exist.'
        ) AS message;
    ELSEIF NOT ufn_DoesColumnExist(in_table_name, in_column_name) THEN
        SELECT CONCAT(
            'Foreign key ',
            in_constraint_name,
            ' creation failed due to column ',
            in_column_name,
            ' does not exist on the table ',
            in_table_name, '.'
        ) AS message;
    ELSEIF NOT ufn_DoesTableExist(in_ref_table_name) THEN
        SELECT CONCAT(
            'Foreign key ',
            in_constraint_name,
            ' creation failed due to referenced table ',
            in_ref_table_name,
            ' does not exist.'
        ) AS message;
    ELSEIF NOT ufn_DoesColumnExist(in_ref_table_name, in_ref_column_name) THEN
        SELECT CONCAT(
            'Foreign key ',
            in_constraint_name,
            ' creation failed due to referenced column ',
            in_ref_column_name,
            ' does not exist on the table ',
            in_ref_table_name, '.'
        ) AS message;
    ELSEIF EXISTS (
        SELECT 1
        FROM information_schema.key_column_usage
        WHERE table_schema = DATABASE()
          AND table_name = in_table_name
          AND column_name = in_column_name
          AND referenced_table_name IS NOT NULL
    ) THEN
        SELECT CONCAT(
            'Foreign key ',
            in_constraint_name,
            ' already exists.'
        ) AS message;
    ELSE
        BEGIN
            DECLARE EXIT HANDLER FOR SQLEXCEPTION
            BEGIN
                SELECT CONCAT(
                    'Foreign key ',
                    in_constraint_name,
                    ' creation failed.'
                ) AS message;
            END;

            SET @sql = CONCAT(
                'ALTER TABLE ', in_table_name,
                ' ADD CONSTRAINT ', in_constraint_name,
                ' FOREIGN KEY (', in_column_name, ')',
                ' REFERENCES ', in_ref_table_name, '(', in_ref_column_name, ')'
            );
            PREPARE stmt FROM @sql;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;

            SELECT CONCAT(
                'Foreign key ',
                in_constraint_name,
                ' created successfully.'
            ) AS message;
        END;
    END IF;
END
$$

DELIMITER
