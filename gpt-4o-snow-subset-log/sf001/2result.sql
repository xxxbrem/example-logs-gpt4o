SELECT 
    "POSTAL_CODE", 
    "DATE_VALID_STD", 
    "TOT_SNOWFALL_IN"
FROM 
    "GLOBAL_WEATHER__CLIMATE_DATA_FOR_BI"."STANDARD_TILE"."HISTORY_DAY"
WHERE 
    "COUNTRY" = 'US' 
    AND "TOT_SNOWFALL_IN" > 6
    AND "DOY_STD" BETWEEN 22 AND 28 -- Week ending after the first two full weeks of the previous year (DOY 15-21 is the second full week; next week ending is 22-28)
ORDER BY 
    "POSTAL_CODE", 
    "DATE_VALID_STD";