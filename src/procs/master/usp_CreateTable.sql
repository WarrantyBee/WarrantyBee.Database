DELIMITER $$
DROP PROCEDURE IF EXISTS usp_CreateTable$$

-- =============================================
-- usp_CreateTable
-- Creates a table with columns 'id', 'created_by', 'updated_by', 'created_at', and 'updated_at'
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
--   - The created table will have columns: id INT AUTO_INCREMENT, created_by INT, updated_by INT,
--     created_at TIMESTAMP DEFAULT CURRENT_UTCTIMESTAMP, updated_at TIMESTAMP.
--   - After creation, it calls usp_CreatePrimaryKey to add the primary key constraint named pk_{table}.id.
--   - Prints messages for every execution flow and handles exceptions.
-- =============================================

CREATE PROCEDURE usp_CreateTable(
    IN in_table_name VARCHAR(64)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT CONCAT(
            'Table ',
            in_table_name,
            ' creation failed due to an exception.'
        ) AS message;
    END;

    IF ufn_DoesTableExist(in_table_name) THEN
        SELECT CONCAT(
            'Table ',
            in_table_name,
            ' already exists.'
        ) AS message;
    ELSE
        SET @sql = CONCAT(
            'CREATE TABLE ', in_table_name, ' (',
                'id INT AUTO_INCREMENT, ',
                'created_by INT, ',
                'updated_by INT, ',
                'created_at TIMESTAMP DEFAULT CURRENT_UTCTIMESTAMP, ',
                'updated_at TIMESTAMP',
            ')'
        );
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        CALL usp_CreatePrimaryKey(in_table_name, 'id', CONCAT('pk_', in_table_name, '.id'));

        SELECT CONCAT(
            'Table ',
            in_table_name,
            ' created successfully.'
        ) AS message;
    END IF;
END
$$

DELIMITER ;
