-- Corrected SQL query: Removed references to non-existent 'BIKE_DATA' and 'WEATHER_DATA' and kept only NOAA data
-- Step 1: Retrieve the average, maximum, and minimum temperatures for Central Park on July 15, 2015
WITH central_park_weather AS (
    SELECT 
        "temp" AS avg_temp, 
        "max" AS max_temp, 
        "min" AS min_temp
    FROM NOAA_DATA.NOAA_GSOD.GSOD2015
    WHERE "wban" = '94728'
      AND "year" = '2015'
      AND "mo" = '07' 
      AND "da" = '15'
)

-- Final Step: Output the retrieved weather data (since no bike trip or ZIP Code data exists in the database)
SELECT *
FROM central_park_weather;