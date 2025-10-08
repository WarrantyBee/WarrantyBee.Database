CALL usp_CreateUniqueKey('tblCompanies', 'name');

-- Add check constraints for data validation
CALL usp_AddCheck('tblCompanies', 'contact_phone', "`contact_phone` REGEXP '^[0-9()\\-\\s+]+$'");
CALL usp_AddCheck('tblCompanies', 'zip_code', "`zip_code` REGEXP '^[A-Za-z0-9\\-]+$'");
CALL usp_AddCheck('tblCompanies', 'support_email', "`support_email` REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$'");