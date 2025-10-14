DELIMITER $$
DROP PROCEDURE IF EXISTS usp_ResetAutoIncrement$$

-- =============================================
-- usp_ResetAutoIncrement
-- Resets the auto-increment value of a table to the current maximum value of the primary key.
--
-- Parameters:
--   in_table_name    - The name of the table to modify.
--
-- Usage:
--   CALL usp_ResetAutoIncrement('tblExample');
--
-- Notes:
--   - This procedure assumes that the primary key is a single auto-incrementing column.
--   - It finds the maximum value of the primary key and sets the next auto-increment value to max + 1.
--   - If the table is empty, it resets the auto-increment value to 1.
-- =============================================

CREATE PROCEDURE usp_ResetAutoIncrement(
    IN in_table_name VARCHAR(64)
)
BEGIN
    DECLARE v_max_id BIGINT;
    DECLARE v_pk_column_name VARCHAR(64);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT CONCAT(
            'Failed to reset auto-increment for table ',
            in_table_name,
            ' due to an exception.'
        ) AS message;
    END;

    IF NOT ufn_DoesTableExist(in_table_name) THEN
        SELECT CONCAT(
            'Failed to reset auto-increment because table ',
            in_table_name,
            ' does not exist.'
        ) AS message;
    ELSE
        SELECT kcu.column_name INTO v_pk_column_name
        FROM information_schema.table_constraints AS tc
        JOIN information_schema.key_column_usage AS kcu
            ON tc.constraint_name = kcu.constraint_name
            AND tc.table_schema = kcu.table_schema
            AND tc.table_name = kcu.table_name
        WHERE tc.constraint_type = 'PRIMARY KEY'
          AND tc.table_schema = DATABASE()
          AND tc.table_name = in_table_name
        LIMIT 1;

        IF v_pk_column_name IS NULL THEN
            SELECT CONCAT(
                'Failed to reset auto-increment because table ',
                in_table_name,
                ' does not have a primary key.'
            ) AS message;
        ELSE
            SET @sql = CONCAT('SELECT MAX(', v_pk_column_name, ') INTO @max_id FROM ', in_table_name);
            PREPARE stmt FROM @sql;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;

            SET v_max_id = @max_id;

            IF v_max_id IS NULL THEN
                SET @sql = CONCAT('ALTER TABLE ', in_table_name, ' AUTO_INCREMENT = 1');
            ELSE
                SET @sql = CONCAT('ALTER TABLE ', in_table_name, ' AUTO_INCREMENT = ', v_max_id + 1);
            END IF;

            PREPARE stmt FROM @sql;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;

            SELECT CONCAT(
                'Auto-increment for table ',
                in_table_name,
                ' has been reset successfully.'
            ) AS message;
        END IF;
    END IF;
END$$

DELIMITER ;

SELECT 'usp_ResetAutoIncrement created successfully.' AS message;
