CREATE OR ALTER PROCEDURE usp_AdminCreateUser(
    @in_firstname VARCHAR(128),
    @in_lastname VARCHAR(128),
    @in_email VARCHAR(255),
    @in_password VARCHAR(1024),
    @in_role_id BIGINT,
    @in_phone_code VARCHAR(8),
    @in_phone_number VARCHAR(15),
    @in_gender TINYINT,
    @in_country_id BIGINT,
    @in_region_id BIGINT,
    @in_city VARCHAR(255),
    @in_postal_code VARCHAR(20),
    @in_culture_id BIGINT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_user_id BIGINT;
    DECLARE @v_record_exists INT = 0;
    DECLARE @v_disabled BIT = 0;
    DECLARE @v_accepted BIT = 1;

    BEGIN TRY
        -- Basic validations
        IF @in_firstname IS NULL OR LTRIM(RTRIM(@in_firstname)) = ''
            THROW 50000, 'First name is required.', 1;
        
        IF @in_lastname IS NULL OR LTRIM(RTRIM(@in_lastname)) = ''
            THROW 50000, 'Last name is required.', 1;

        IF @in_email IS NULL OR @in_email NOT LIKE '%_@__%.__%'
            THROW 50000, 'A valid email address is required.', 1;

        SELECT @v_record_exists = COUNT(1) FROM tblUsers WHERE email = @in_email;
        IF @v_record_exists > 0
            THROW 50000, 'This email address is already registered.', 1;

        SELECT @v_record_exists = COUNT(1) FROM tblRoles WHERE id = @in_role_id;
        IF @v_record_exists = 0
            THROW 50000, 'The specified role does not exist.', 1;

        BEGIN TRANSACTION;

        INSERT INTO tblUsers (
            firstname, lastname, email, [password], 
            is_2fa_enabled, accepted_tnc, accepted_pp, 
            auth_provider, role_id
        )
        VALUES (
            LTRIM(RTRIM(@in_firstname)), LTRIM(RTRIM(@in_lastname)), 
            LTRIM(RTRIM(@in_email)), @in_password,
            @v_disabled, @v_accepted, @v_accepted, 
            1, -- Internal Auth
            @in_role_id
        );
        SET @v_user_id = SCOPE_IDENTITY();

        INSERT INTO tblUserProfiles (
            user_id, phone_code, phone_number, gender,
            country_id, region_id, city, postal_code, culture_id
        ) VALUES (
            @v_user_id, @in_phone_code, @in_phone_number, @in_gender,
            @in_country_id, @in_region_id, @in_city, @in_postal_code, @in_culture_id
        );

        COMMIT;

        SELECT @v_user_id AS inserted_id, 'Success' AS message;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT NULL AS inserted_id, ERROR_MESSAGE() AS message;
    END CATCH
END;
GO
