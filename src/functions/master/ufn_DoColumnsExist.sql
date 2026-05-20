-- =============================================
-- ufn_DoColumnsExist
-- Checks if a comma-separated list of columns exists in a given table.
--
-- Parameters:
--   @in_table_name   - The name of the table to check.
--   @in_column_names - A comma-separated string of column names.
--
-- Returns:
--   1 (TRUE) if all columns exist, otherwise 0 (FALSE).
-- =============================================

IF OBJECT_ID('dbo.ufn_DoColumnsExist', 'FN') IS NOT NULL
    DROP FUNCTION dbo.ufn_DoColumnsExist;
GO

CREATE FUNCTION dbo.ufn_DoColumnsExist(
    @in_table_name NVARCHAR(128),
    @in_column_names NVARCHAR(MAX)
)
RETURNS BIT
AS
BEGIN
    DECLARE @col_name NVARCHAR(128);
    DECLARE @remaining_cols NVARCHAR(MAX) = @in_column_names;
    DECLARE @comma_pos INT;

    WHILE @remaining_cols IS NOT NULL AND @remaining_cols != ''
    BEGIN
        SET @comma_pos = CHARINDEX(',', @remaining_cols);
        IF @comma_pos > 0
        BEGIN
            SET @col_name = LTRIM(RTRIM(RTRIM(SUBSTRING(@remaining_cols, 1, @comma_pos - 1))));
            SET @remaining_cols = LTRIM(RTRIM(RTRIM(SUBSTRING(@remaining_cols, @comma_pos + 1, LEN(@remaining_cols)))));
        END
        ELSE
        BEGIN
            SET @col_name = LTRIM(RTRIM(RTRIM(@remaining_cols)));
            SET @remaining_cols = '';
        END

        IF dbo.ufn_DoesColumnExist(@in_table_name, @col_name) = 0
        BEGIN
            RETURN 0;
        END
    END

    RETURN 1;
END
GO


