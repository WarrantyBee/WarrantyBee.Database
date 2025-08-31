CALL usp_CreateForeignKey(
    'tblRegions',
    'country_id',
    'tblCountries',
    'id'
);

CALL usp_CreateForeignKey(
    'tblRegions',
    'timezone_id',
    'tblTimeZones',
    'id'
);

CALL usp_CreateForeignKey(
    'tblRegions',
    'currency_id',
    'tblCurrencies',
    'id'
);