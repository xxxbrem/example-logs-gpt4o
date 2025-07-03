SELECT 
    "wban",
    "year",
    "mo",
    "da",
    "temp" AS "average_temp"
FROM 
    "NOAA_DATA"."NOAA_GSOD"."GSOD2015"
WHERE 
    "wban" = '94728' 
    AND "year" = '2015' 
    AND "mo" = '07' 
    AND "da" = '15';