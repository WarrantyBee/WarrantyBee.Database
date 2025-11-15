DROP PROCEDURE IF EXISTS usp_CreateColumns_tblUserProfiles;
DELIMITER $$

CREATE PROCEDURE usp_CreateColumns_tblUserProfiles()
BEGIN
    DECLARE v_required BOOLEAN DEFAULT TRUE;
    DECLARE v_optional BOOLEAN DEFAULT FALSE;

    CALL usp_AddColumn('tblUserProfiles', 'phone_number', 'VARCHAR(15)', NULL, v_required);
    CALL usp_AddColumn('tblUserProfiles', 'gender', 'TINYINT', NULL, v_required);
    CALL usp_AddColumn('tblUserProfiles', 'date_of_birth', 'DATE', NULL, v_required);
    CALL usp_AddColumn('tblUserProfiles', 'address_line1', 'VARCHAR(255)', NULL, v_required);
    CALL usp_AddColumn('tblUserProfiles', 'address_line2', 'VARCHAR(255)', NULL, v_optional);
    CALL usp_AddColumn('tblUserProfiles', 'region_id', 'BIGINT UNSIGNED', NULL, v_required);
    CALL usp_AddColumn('tblUserProfiles', 'country_id', 'BIGINT UNSIGNED', NULL, v_required);
    CALL usp_AddColumn('tblUserProfiles', 'city', 'VARCHAR(255)', NULL, v_required);
    CALL usp_AddColumn('tblUserProfiles', 'postal_code', 'VARCHAR(20)', NULL, v_required);
    CALL usp_AddColumn('tblUserProfiles', 'avatar_url', 'VARCHAR(512)', NULL, v_optional);
    CALL usp_AddColumn('tblUserProfiles', 'user_id', 'BIGINT UNSIGNED', NULL, v_required);
    CALL usp_AddColumn('tblUserProfiles', 'culture_id', 'BIGINT UNSIGNED', '1', v_required);

    ALTER TABLE tblUserProfiles
    MODIFY COLUMN created_by
    BIGINT UNSIGNED DEFAULT NULL;
END$$

DELIMITER ;

CALL usp_CreateColumns_tblUserProfiles();
DROP PROCEDURE usp_CreateColumns_tblUserProfiles;