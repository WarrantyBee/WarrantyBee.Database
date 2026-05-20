CREATE OR ALTER PROCEDURE usp_ResetPassword(
    @in_user_id BIGINT,
    @in_new_password VARCHAR(255)
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_old_password VARCHAR(255);
    DECLARE @v_password_updated_at DATETIME2;
    DECLARE @v_user_found BIT = 0;
    DECLARE @v_error_message VARCHAR(255);

    BEGIN TRY
        IF @in_user_id IS NULL
        BEGIN
            SET @v_error_message = 'User identifier must be provided.';
            THROW 50000, @v_error_message, 1;
        END;

        IF @in_new_password IS NULL OR LTRIM(RTRIM(@in_new_password)) = ''
        BEGIN
            SET @v_error_message = 'New password must be provided.';
            THROW 50000, @v_error_message, 1;
        END;

        IF EXISTS (SELECT 1 FROM tblUsers WHERE id = @in_user_id)
        BEGIN
            SET @v_user_found = 1;
        END;

        IF @v_user_found = 0
        BEGIN
            SET @v_error_message = 'User not found.';
            THROW 50000, @v_error_message, 1;
        END;

        SELECT @v_password_updated_at = password_updated_at
        FROM tblUsers
        WHERE id = @in_user_id;

        IF @v_password_updated_at IS NOT NULL AND
        GETUTCDATE() BETWEEN @v_password_updated_at AND DATEADD(MINUTE, 10, @v_password_updated_at)
        BEGIN
            SELECT -1 AS [status], 'Password was recently updated. Please wait before resetting again.' AS [message];
            RETURN;
        END;

        BEGIN TRANSACTION;

        SELECT @v_old_password = [password]
        FROM tblUsers
        WHERE id = @in_user_id;

        UPDATE tblUsers
        SET [password] = @in_new_password,
            password_updated_at = GETUTCDATE()
        WHERE id = @in_user_id;

        IF @v_old_password IS NOT NULL
        BEGIN
            INSERT INTO tblPasswordLogs (user_id, [password])
            VALUES (@in_user_id, @v_old_password);
        END;

        COMMIT;
        
        SELECT 0 AS [status], 'Success' AS [message];
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        SELECT 1 AS [status], ERROR_MESSAGE() AS [message];
    END CATCH
END;



