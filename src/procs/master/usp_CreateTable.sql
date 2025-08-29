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
                'id INT',
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
        CALL usp_AddColumn(in_table_name, 'created_by', 'INT', NULL, TRUE);
        CALL usp_AddColumn(in_table_name, 'updated_by', 'INT', NULL, FALSE);
        CALL usp_AddColumn(in_table_name, 'created_at', 'TIMESTAMP', 'UTC_TIMESTAMP', TRUE);
        CALL usp_AddColumn(in_table_name, 'updated_at', 'TIMESTAMP', NULL, FALSE);
        CALL usp_AddColumn(in_table_name, 'void', 'BOOLEAN', '0', FALSE);

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