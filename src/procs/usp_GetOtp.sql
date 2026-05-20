CREATE OR ALTER PROCEDURE usp_GetOtp(
    @in_recipient VARCHAR(255),
    @in_recipient_id BIGINT,
    @in_type TINYINT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_active BIT = 0;
    DECLARE @v_expired BIT = 1;

    BEGIN TRY
        IF @in_recipient IS NULL OR LTRIM(RTRIM(@in_recipient)) = ''
        BEGIN
            THROW 50000, 'Recipient must be provided.', 1;
        END;

        IF @in_type IS NULL
        BEGIN
            THROW 50000, 'Type must be provided.', 1;
        END;

        SELECT 0 AS [status], 'Success' AS [message];

        SELECT TOP 1
            id,
            value,
            recipient,
            recipient_id,
            [type]
        FROM
            tblOtp
        WHERE
            recipient = @in_recipient AND
            (@in_recipient_id IS NULL OR recipient_id = @in_recipient_id) AND
            [type] = @in_type AND
            GETUTCDATE() BETWEEN created_at AND DATEADD(MINUTE, 10, created_at) AND
            void = @v_active
        ORDER BY
            created_at DESC;

        UPDATE tblOtp
        SET void = @v_expired
        WHERE recipient = @in_recipient
        AND [type] = @in_type;
    END TRY
    BEGIN CATCH
        SELECT 1 AS [status], ERROR_MESSAGE() AS [message];
    END CATCH
END;


