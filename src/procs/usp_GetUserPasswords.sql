CREATE OR ALTER PROCEDURE usp_GetUserPasswords(
    @in_user_id BIGINT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF @in_user_id IS NULL
        BEGIN
            THROW 50000, 'User ID is required.', 1;
        END;

        SELECT [password] FROM tblUsers WHERE id = @in_user_id
        UNION ALL
        SELECT [password] FROM tblPasswordLogs WHERE user_id = @in_user_id;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;

