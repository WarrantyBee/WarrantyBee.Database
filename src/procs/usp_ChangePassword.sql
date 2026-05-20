IF OBJECT_ID('dbo.usp_ChangePassword', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_ChangePassword;
GO

-- =============================================
-- usp_ChangePassword
-- Changes a user's password after verifying the old password.
--
-- Parameters:
--   @in_user_id       - The user's unique identifier.
--   @in_old_password  - The user's current password.
--   @in_new_password  - The new password to set.
-- =============================================
CREATE PROCEDURE dbo.usp_ChangePassword(
    @in_user_id BIGINT,
    @in_old_password VARCHAR(1024),
    @in_new_password VARCHAR(1024)
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_current_password VARCHAR(1024);
    DECLARE @v_user_exists BIT = 0;

    BEGIN TRY
        -- Parameter validation
        IF @in_user_id IS NULL OR @in_old_password IS NULL OR @in_new_password IS NULL
        BEGIN
            THROW 50000, 'All parameters must be provided.', 1;
        END

        -- Check if the user exists
        IF dbo.ufn_DoesUserExist(@in_user_id, NULL) = 0
        BEGIN
            THROW 50000, 'User not found.', 1;
        END

        -- Retrieve the current password
        SELECT @v_current_password = [password] FROM tblUsers WHERE id = @in_user_id;

        -- Verify the old password
        IF @v_current_password != @in_old_password
        BEGIN
            THROW 50000, 'Incorrect old password.', 1;
        END

        -- Check if the new password is the same as the old one
        IF @in_new_password = @in_old_password
        BEGIN
            SELECT -1 AS status, 'New password cannot be the same as the old password.' AS message;
            RETURN;
        END

        -- Start transaction
        BEGIN TRANSACTION;

        -- Update the password
        UPDATE tblUsers SET [password] = @in_new_password, password_updated_at = GETUTCDATE() WHERE id = @in_user_id;

        -- Log the old password
        INSERT INTO tblPasswordLogs (user_id, [password]) VALUES (@in_user_id, @v_current_password);

        -- Commit the transaction
        COMMIT TRANSACTION;

        -- Return success message
        SELECT 0 AS status, 'Password changed successfully.' AS message;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT 1 AS status, ERROR_MESSAGE() AS message;
    END CATCH
END
GO

PRINT 'usp_ChangePassword created successfully.';

