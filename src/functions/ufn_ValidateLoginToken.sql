IF OBJECT_ID('dbo.ufn_ValidateLoginToken', 'FN') IS NOT NULL
    DROP FUNCTION dbo.ufn_ValidateLoginToken;
GO

-- =============================================
-- ufn_ValidateLoginToken
-- Validates the login token for a user.
--
-- Parameters:
--   @in_user_id   - The user's identifier.
--   @in_token     - The login token to validate.
--
-- Returns:
--   1 if the token is valid, 0 otherwise.
-- =============================================
CREATE FUNCTION dbo.ufn_ValidateLoginToken(
    @in_user_id BIGINT,
    @in_token VARCHAR(255)
)
RETURNS BIT
AS
BEGIN
    DECLARE @v_stored_token VARCHAR(255);

    IF @in_user_id IS NULL OR @in_token IS NULL OR LTRIM(RTRIM(@in_token)) = ''
    BEGIN
        RETURN 0;
    END

    SELECT @v_stored_token = login_token
    FROM tblUsers
    WHERE id = @in_user_id;

    IF @v_stored_token IS NOT NULL AND @v_stored_token = @in_token
    BEGIN
        RETURN 1;
    END

    RETURN 0;
END
GO


