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

SELECT 'usp_CreateIndex created successfully.' AS message;