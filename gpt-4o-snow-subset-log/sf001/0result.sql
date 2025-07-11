SELECT 
    "POSTAL_CODE", 
    "DATE_VALID_STD", 
    "TOT_SNOWFALL_IN" 
FROM GLOBAL_WEATHER__CLIMATE_DATA_FOR_BI.STANDARD_TILE.HISTORY_DAY 
WHERE 
    "COUNTRY" = 'US' 
    AND "TOT_SNOWFALL_IN" > 6 
    AND "DATE_VALID_STD" BETWEEN '2023-12-25' AND '2023-12-31'
ORDER BY "DATE_VALID_STD" ASC, "POSTAL_CODE" ASC;