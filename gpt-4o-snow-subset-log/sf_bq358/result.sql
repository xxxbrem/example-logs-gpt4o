WITH weather_data AS (
    SELECT DISTINCT 
        "year", 
        "mo", 
        "da", 
        "temp"
    FROM 
        "NOAA_DATA"."NOAA_GSOD"."GSOD2015"
    WHERE 
        "wban" = '94728'
        AND "year" = '2015'
        AND "mo" = '07'
        AND "da" = '15'
),
highest_temp_zips AS (
    SELECT DISTINCT 
        "latitude", 
        "longitude", 
        "location",
        "county",
        "state", 
        "timestamp"
    FROM 
        "NOAA_DATA"."NOAA_PRELIMINARY_SEVERE_STORMS"."TORNADO_REPORTS"
)
SELECT *
FROM highest_temp_zips;