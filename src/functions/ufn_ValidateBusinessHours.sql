DROP FUNCTION IF EXISTS ufn_ValidateBusinessHours;

DELIMITER $$

-- =============================================
-- ufn_ValidateBusinessHours
-- Validates a JSON object representing business hours for a week.
-- It checks for the correct structure, valid time formats, and ensures
-- that there are no overlapping time slots for any given day.
--
-- Parameters:
--   businessHours - A JSON object representing the business hours.
--                   The object must contain keys for all seven days of the week
--                   ('mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun').
--                   Each day's value is an array of time slots.
--                   Each time slot is an object with 'startTime' and 'endTime' in 'HH:MM' format.
--
-- Returns:
--   TINYINT(1): Returns 1 if the JSON is valid, and 0 otherwise.
-- =============================================
CREATE FUNCTION ufn_ValidateBusinessHours(businessHours JSON)
RETURNS TINYINT(1)
DETERMINISTIC
BEGIN
    DECLARE days_of_week JSON;
    DECLARE day_key VARCHAR(3);
    DECLARE day_array JSON;
    DECLARE day_index INT DEFAULT 0;
    DECLARE slot_count INT;
    DECLARE invalid_count INT;

    IF NOT JSON_VALID(businessHours) OR JSON_TYPE(businessHours) != 'OBJECT' THEN
        RETURN 0;
    END IF;

    SET days_of_week = JSON_ARRAY('mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun');
    IF NOT JSON_CONTAINS_PATH(businessHours, 'all', '$.mon', '$.tue', '$.wed', '$.thu', '$.fri', '$.sat', '$.sun') THEN
        RETURN 0;
    END IF;

    IF JSON_LENGTH(businessHours) != 7 THEN
        RETURN 0;
    END IF;

    WHILE day_index < 7 DO
        SET day_key = JSON_UNQUOTE(JSON_EXTRACT(days_of_week, CONCAT('$[', day_index, ']')));
        SET day_array = JSON_EXTRACT(businessHours, CONCAT('$.', day_key));

        IF JSON_TYPE(day_array) != 'ARRAY' THEN
            RETURN 0;
        END IF;

        SET slot_count = JSON_LENGTH(day_array);

        IF slot_count > 0 THEN
            SELECT COUNT(*) INTO invalid_count
            FROM JSON_TABLE(day_array, '$[*]' COLUMNS (
                has_startTime TINYINT(1) EXISTS PATH '$.startTime',
                has_endTime TINYINT(1) EXISTS PATH '$.endTime',
                startTime VARCHAR(5) PATH '$.startTime',
                endTime VARCHAR(5) PATH '$.endTime'
            )) AS slots
            WHERE
                NOT has_startTime OR
                NOT has_endTime OR
                STR_TO_DATE(startTime, '%H:%i') IS NULL OR
                STR_TO_DATE(endTime, '%H:%i') IS NULL OR
                STR_TO_DATE(startTime, '%H:%i') >= STR_TO_DATE(endTime, '%H:%i');

            IF invalid_count > 0 THEN
                RETURN 0;
            END IF;

            IF slot_count > 1 THEN
                SELECT COUNT(*) INTO invalid_count
                FROM (
                    SELECT
                        end_time,
                        LEAD(start_time, 1) OVER (ORDER BY start_time) AS next_start_time
                    FROM JSON_TABLE(
                        day_array,
                        '$[*]' COLUMNS (
                            start_time TIME PATH '$.startTime',
                            end_time TIME PATH '$.endTime'
                        )
                    ) AS slots
                ) AS ordered_slots
                WHERE end_time > next_start_time;

                IF invalid_count > 0 THEN
                    RETURN 0;
                END IF;
            END IF;
        END IF;

        SET day_index = day_index + 1;
    END WHILE;

    RETURN 1;
END$$

DELIMITER ;
