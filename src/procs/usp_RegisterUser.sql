CREATE OR ALTER PROCEDURE usp_RegisterUser(
    @in_firstname VARCHAR(128),
    @in_lastname VARCHAR(128),
    @in_email VARCHAR(255),
    @in_password VARCHAR(1024),
    @in_accepted_tnc BIT,
    @in_accepted_pp BIT,
    @in_phone_code VARCHAR(8),
    @in_phone_number VARCHAR(15),
    @in_gender TINYINT,
    @in_date_of_birth DATE,
    @in_address_line1 VARCHAR(255),
    @in_address_line2 VARCHAR(255),
    @in_country_id BIGINT,
    @in_region_id BIGINT,
    @in_city VARCHAR(255),
    @in_postal_code VARCHAR(20),
    @in_avatar_url VARCHAR(512),
    @in_culture_id BIGINT,
    @in_auth_provider TINYINT,
    @in_auth_provider_user_id VARCHAR(1024)
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_user_id BIGINT;
    DECLARE @v_record_exists INT = 0;
    DECLARE @v_not_accepted BIT = 0;
    DECLARE @v_disabled BIT = 0;
    DECLARE @v_gender_male TINYINT = 1;
    DECLARE @v_gender_female TINYINT = 2;
    DECLARE @v_gender_not_specified TINYINT = 3;
    DECLARE @v_auth_provider_internal TINYINT = 1;
    DECLARE @v_auth_provider_facebook TINYINT = 2;
    DECLARE @v_auth_provider_google TINYINT = 3;
    DECLARE @v_auth_provider_linkedin TINYINT = 4;
    DECLARE @v_customer_role BIGINT = NULL;

    BEGIN TRY
        IF @in_accepted_tnc = @v_not_accepted
        BEGIN
            THROW 50000, 'Terms and Conditions must be accepted.', 1;
        END;
        
        IF @in_accepted_pp = @v_not_accepted
        BEGIN
            THROW 50000, 'Privacy Policy must be accepted.', 1;
        END;
        
        IF @in_firstname IS NULL OR LTRIM(RTRIM(@in_firstname)) = ''
        BEGIN
            THROW 50000, 'First name is required.', 1;
        END;
        
        IF @in_lastname IS NULL OR LTRIM(RTRIM(@in_lastname)) = ''
        BEGIN
            THROW 50000, 'Last name is required.', 1;
        END;
        
        IF @in_phone_code IS NULL OR LTRIM(RTRIM(@in_phone_code)) = ''
        BEGIN
            THROW 50000, 'Phone code is required.', 1;
        END;
        
        IF @in_phone_number IS NULL OR LTRIM(RTRIM(@in_phone_number)) = ''
        BEGIN
            THROW 50000, 'Phone number is required.', 1;
        END;
        
        IF @in_address_line1 IS NULL OR LTRIM(RTRIM(@in_address_line1)) = ''
        BEGIN
            THROW 50000, 'Address line 1 is required.', 1;
        END;
        
        IF @in_city IS NULL OR LTRIM(RTRIM(@in_city)) = ''
        BEGIN
            THROW 50000, 'City is required.', 1;
        END;
        
        IF @in_postal_code IS NULL OR LTRIM(RTRIM(@in_postal_code)) = ''
        BEGIN
            THROW 50000, 'Postal code is required.', 1;
        END;

        IF @in_email IS NULL OR @in_email NOT LIKE '%_@__%.__%'
        BEGIN
            THROW 50000, 'A valid email address is required.', 1;
        END;

        SELECT @v_record_exists = COUNT(1) FROM tblUsers WHERE email = @in_email;
        IF @v_record_exists > 0
        BEGIN
            THROW 50000, 'This email address is already registered.', 1;
        END;

        IF @in_gender NOT IN (@v_gender_male, @v_gender_female, @v_gender_not_specified)
        BEGIN
            THROW 50000, 'Invalid gender specified. Allowed values are 1, 2, 3.', 1;
        END;

        IF @in_date_of_birth IS NULL OR @in_date_of_birth > CAST(GETUTCDATE() AS DATE)
        BEGIN
            THROW 50000, 'Date of birth cannot be in the future.', 1;
        END;

        SELECT @v_record_exists = COUNT(1) FROM tblCountries WHERE id = @in_country_id;
        IF @v_record_exists = 0
        BEGIN
            THROW 50000, 'The specified country does not exist.', 1;
        END;

        SELECT @v_record_exists = COUNT(1) FROM tblStates WHERE id = @in_region_id AND country_id = @in_country_id;
        IF @v_record_exists = 0
        BEGIN
            THROW 50000, 'The specified region is not valid for the selected country.', 1;
        END;

        SELECT @v_record_exists = COUNT(1) FROM tblCultures WHERE id = @in_culture_id;
        IF @v_record_exists = 0
        BEGIN
            THROW 50000, 'The specified culture does not exist.', 1;
        END;

        IF @in_auth_provider NOT IN (@v_auth_provider_internal, @v_auth_provider_facebook, @v_auth_provider_google, @v_auth_provider_linkedin)
        BEGIN
            THROW 50000, 'The specified auth provider is not supported.', 1;
        END;

        IF @in_auth_provider <> @v_auth_provider_internal AND
            (@in_auth_provider_user_id IS NULL OR LTRIM(RTRIM(@in_auth_provider_user_id)) = '')
        BEGIN
            THROW 50000, 'The auth provider user identifier is required.', 1;
        END;

        SELECT @v_customer_role = id
        FROM tblRoles
        WHERE name = 'customer';

        BEGIN TRANSACTION;

        INSERT INTO tblUsers (
            firstname,
            lastname,
            email,
            [password],
            is_2fa_enabled,
            accepted_tnc,
            accepted_pp,
            auth_provider,
            auth_provider_user_id,
            role_id
        )
        VALUES (
            LTRIM(RTRIM(@in_firstname)),
            LTRIM(RTRIM(@in_lastname)),
            LTRIM(RTRIM(@in_email)),
            CASE WHEN @in_auth_provider = @v_auth_provider_internal THEN @in_password ELSE NULL END,
            @v_disabled,
            @in_accepted_tnc,
            @in_accepted_pp,
            @in_auth_provider,
            @in_auth_provider_user_id,
            @v_customer_role
        );
        SET @v_user_id = SCOPE_IDENTITY();

        INSERT INTO tblUserProfiles (
            user_id,
            phone_code,
            phone_number,
            gender,
            date_of_birth,
            address_line1,
            address_line2,
            country_id,
            region_id,
            city,
            postal_code,
            avatar_url,
            culture_id
        ) VALUES (
            @v_user_id,
            LTRIM(RTRIM(@in_phone_code)),
            LTRIM(RTRIM(@in_phone_number)),
            @in_gender,
            @in_date_of_birth,
            LTRIM(RTRIM(@in_address_line1)),
            CASE WHEN @in_address_line2 IS NULL OR LTRIM(RTRIM(@in_address_line2)) = '' THEN NULL ELSE LTRIM(RTRIM(@in_address_line2)) END,
            @in_country_id,
            @in_region_id,
            LTRIM(RTRIM(@in_city)),
            LTRIM(RTRIM(@in_postal_code)),
            CASE WHEN @in_avatar_url IS NULL OR LTRIM(RTRIM(@in_avatar_url)) = '' THEN NULL ELSE LTRIM(RTRIM(@in_avatar_url)) END,
            @in_culture_id
        );

        COMMIT;

        SELECT @v_user_id AS inserted_id, 'Success' AS message;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        SELECT NULL AS inserted_id, ERROR_MESSAGE() AS message;
    END CATCH
END;



