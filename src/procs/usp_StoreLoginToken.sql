CREATE OR ALTER PROCEDURE usp_StoreLoginToken(
    @in_user_id BIGINT,
    @in_token VARCHAR(255)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF @in_user_id IS NULL
        BEGIN
            THROW 50000, 'User identifier must be provided.', 1;
        END;

        IF @in_token IS NULL OR LTRIM(RTRIM(@in_token)) = ''
        BEGIN
            THROW 50000, 'Token must be provided.', 1;
        END;

        UPDATE tblUsers
        SET login_token = @in_token
        WHERE id = @in_user_id;

        SELECT 0 AS [status], 'Success' AS [message];
    END TRY
    BEGIN CATCH
        SELECT 1 AS [status], ERROR_MESSAGE() AS [message];
    END CATCH
END;



