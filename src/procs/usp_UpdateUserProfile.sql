CREATE OR ALTER PROCEDURE usp_UpdateUserProfile(
    @in_user_id BIGINT,
    @in_address_line1 VARCHAR(255),
    @in_address_line2 VARCHAR(255),
    @in_phone_code VARCHAR(8),
    @in_phone_number VARCHAR(15),
    @in_country_id BIGINT,
    @in_region_id BIGINT,
    @in_culture_id BIGINT,
    @in_city VARCHAR(255),
    @in_postal_code VARCHAR(20),
    @in_avatar_url VARCHAR(512)
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_record_exists INT = 0;

    BEGIN TRY
        SELECT @v_record_exists = COUNT(1) FROM tblUsers WHERE id = @in_user_id;
        IF @v_record_exists = 0
        BEGIN
            THROW 50000, 'The specified user does not exist.', 1;
        END;

        IF @in_country_id IS NOT NULL
        BEGIN
            SELECT @v_record_exists = COUNT(1) FROM tblCountries WHERE id = @in_country_id;
            IF @v_record_exists = 0
            BEGIN
                THROW 50000, 'The specified country does not exist.', 1;
            END;
        END;

        IF @in_region_id IS NOT NULL
        BEGIN
            SELECT @v_record_exists = COUNT(1) 
            FROM tblStates 
            WHERE id = @in_region_id 
            AND country_id = ISNULL(@in_country_id, (SELECT country_id FROM tblUserProfiles WHERE user_id = @in_user_id));
            
            IF @v_record_exists = 0
            BEGIN
                THROW 50000, 'The specified region is not valid for the selected country.', 1;
            END;
        END;

        IF @in_culture_id IS NOT NULL
        BEGIN
            SELECT @v_record_exists = COUNT(1) FROM tblCultures WHERE id = @in_culture_id;
            IF @v_record_exists = 0
            BEGIN
                THROW 50000, 'The specified culture does not exist.', 1;
            END;
        END;

        BEGIN TRANSACTION;

        UPDATE tblUserProfiles
        SET
            address_line1 = ISNULL(TRIM(@in_address_line1), address_line1),
            address_line2 = CASE WHEN @in_address_line2 IS NULL THEN address_line2 ELSE TRIM(@in_address_line2) END,
            phone_code = ISNULL(TRIM(@in_phone_code), phone_code),
            phone_number = ISNULL(TRIM(@in_phone_number), phone_number),
            country_id = ISNULL(@in_country_id, country_id),
            region_id = ISNULL(@in_region_id, region_id),
            culture_id = ISNULL(@in_culture_id, culture_id),
            city = ISNULL(TRIM(@in_city), city),
            postal_code = ISNULL(TRIM(@in_postal_code), postal_code),
            avatar_url = CASE WHEN @in_avatar_url IS NULL THEN avatar_url ELSE TRIM(@in_avatar_url) END
        WHERE
            user_id = @in_user_id;

        COMMIT;

        SELECT 1 AS success, 'User profile updated successfully.' AS message;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        SELECT 0 AS success, ERROR_MESSAGE() AS message;
    END CATCH
END;

