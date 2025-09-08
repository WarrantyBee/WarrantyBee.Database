CALL usp_CreateForeignKey(
    'tblStates',
    'country_id',
    'tblCountries',
    'id'
);

CALL usp_CreateForeignKey(
    'tblStates',
    'timezone_id',
    'tblTimeZones',
    'id'
);

CALL usp_CreateForeignKey(
    'tblStates',
    'currency_id',
    'tblCurrencies',
    'id'
);