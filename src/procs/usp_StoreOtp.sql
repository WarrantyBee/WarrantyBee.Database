CREATE OR ALTER PROCEDURE usp_StoreOtp(
    @in_value VARCHAR(255),
    @in_recipient VARCHAR(255),
    @in_recipient_id BIGINT,
    @in_type TINYINT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF @in_value IS NULL OR LTRIM(RTRIM(@in_value)) = ''
        BEGIN
            THROW 50000, 'Value is required.', 1;
        END;

        IF @in_recipient IS NULL OR LTRIM(RTRIM(@in_recipient)) = ''
        BEGIN
            THROW 50000, 'Recipient is required.', 1;
        END;

        IF @in_type IS NULL
        BEGIN
            THROW 50000, 'Type is required.', 1;
        END;

        BEGIN TRANSACTION;

        DELETE FROM tblOtp
        WHERE recipient = @in_recipient
        AND [type] = @in_type;

        INSERT INTO tblOtp (recipient_id, value, recipient, [type])
        VALUES (@in_recipient_id, @in_value, @in_recipient, @in_type);

        COMMIT;

        SELECT SCOPE_IDENTITY() AS id, 'Success' AS message;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        SELECT NULL AS id, ERROR_MESSAGE() AS message;
    END CATCH
END;


