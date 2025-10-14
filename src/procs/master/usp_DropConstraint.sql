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

SELECT 'usp_DropConstraint created successfully.' AS message;