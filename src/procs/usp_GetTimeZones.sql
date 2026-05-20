CREATE OR ALTER PROCEDURE usp_GetTimeZones(
    @in_id BIGINT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        id,
        name,
        abbreviation,
        utc_offset_minutes,
        observes_dst,
        current_offset_minutes
    FROM tblTimeZones
    WHERE (@in_id IS NULL OR id = @in_id)
    ORDER BY utc_offset_minutes, name;
END;

