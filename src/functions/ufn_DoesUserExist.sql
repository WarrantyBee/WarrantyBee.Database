IF OBJECT_ID('dbo.ufn_DoesUserExist', 'FN') IS NOT NULL
    DROP FUNCTION dbo.ufn_DoesUserExist;
GO

-- =============================================
-- ufn_DoesUserExist
-- Checks if a user exists in the tblUsers table based on the user ID or email address.
--
-- Parameters:
--   @in_id - The ID of the user to check.
--   @in_email - The email address of the user to check.
--
-- Returns:
--   BIT - 1 if the user exists, 0 otherwise.
--
-- Usage:
--   SELECT dbo.ufn_DoesUserExist(1, NULL);
--   SELECT dbo.ufn_DoesUserExist(NULL, 'test@example.com');
-- =============================================
CREATE FUNCTION dbo.ufn_DoesUserExist(
    @in_id BIGINT,
    @in_email VARCHAR(255)
)
RETURNS BIT
AS
BEGIN
    DECLARE @v_user_exists BIT;

    IF EXISTS (
        SELECT 1
        FROM tblUsers
        WHERE
            (@in_id IS NOT NULL AND id = @in_id) OR
            (@in_email IS NOT NULL AND email = @in_email)
    )
        SET @v_user_exists = 1;
    ELSE
        SET @v_user_exists = 0;

    RETURN @v_user_exists;
END
GO

