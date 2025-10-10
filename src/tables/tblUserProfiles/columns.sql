DELIMITER $$

CREATE PROCEDURE usp_CreateColumns_tblUserProfiles()
BEGIN
    DECLARE @required BOOLEAN DEFAULT TRUE;
    DECLARE @optional BOOLEAN DEFAULT FALSE;

    CALL usp_AddColumn('tblUserProfiles', 'phone_number', 'VARCHAR(15)', NULL, @required);
    CALL usp_AddColumn('tblUserProfiles', 'gender', 'TINYINT', NULL, @required);
    CALL usp_AddColumn('tblUserProfiles', 'date_of_birth', 'DATE', NULL, @required);
    CALL usp_AddColumn('tblUserProfiles', 'address_line1', 'VARCHAR(255)', NULL, @required);
    CALL usp_AddColumn('tblUserProfiles', 'address_line2', 'VARCHAR(255)', NULL, @optional);
    CALL usp_AddColumn('tblUserProfiles', 'region_id', 'BIGINT UNSIGNED', NULL, @required);
    CALL usp_AddColumn('tblUserProfiles', 'country_id', 'BIGINT UNSIGNED', NULL, @required);
    CALL usp_AddColumn('tblUserProfiles', 'city', 'VARCHAR(255)', NULL, @required);
    CALL usp_AddColumn('tblUserProfiles', 'postal_code', 'VARCHAR(20)', NULL, @required);
    CALL usp_AddColumn('tblUserProfiles', 'avatar_url', 'VARCHAR(512)', NULL, @optional);
    CALL usp_AddColumn('tblUserProfiles', 'user_id', 'BIGINT UNSIGNED', NULL, @required);
END$$

DELIMITER ;

CALL usp_CreateColumns_tblUserProfiles();
DROP PROCEDURE usp_CreateColumns_tblUserProfiles;