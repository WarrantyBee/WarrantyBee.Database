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

SELECT 'ufn_DoColumnsExists created successfully.' AS message;