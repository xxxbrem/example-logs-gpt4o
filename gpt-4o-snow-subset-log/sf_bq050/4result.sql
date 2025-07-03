WITH neighborhood_mapping AS (
    -- Map trip start and end lat/lon to neighborhoods using zip_codes in GEO_US_BOUNDARIES and CYCLISTIC.
    SELECT 
        T."start_station_name",
        T."end_station_name",
        Z1."neighborhood" AS "start_neighborhood",
        Z2."neighborhood" AS "end_neighborhood",
        T."tripduration",
        T."start_station_latitude",
        T."start_station_longitude",
        T."end_station_latitude",
        T."end_station_longitude",
        T."starttime",
        DATE_TRUNC('DAY', TO_TIMESTAMP(T."starttime" / 1000000)) AS "trip_date"
    FROM "NEW_YORK_CITIBIKE_1"."NEW_YORK_CITIBIKE"."CITIBIKE_TRIPS" T
    LEFT JOIN (
        SELECT DISTINCT ZG."zip_code", CZ."neighborhood", ZG."internal_point_lat", ZG."internal_point_lon"
        FROM "NEW_YORK_CITIBIKE_1"."GEO_US_BOUNDARIES"."ZIP_CODES" ZG
        JOIN "NEW_YORK_CITIBIKE_1"."CYCLISTIC"."ZIP_CODES" CZ
        ON TO_NUMBER(ZG."zip_code") = CZ."zip"
    ) Z1
    ON ST_WITHIN(ST_GEOGRAPHYFROMTEXT(CONCAT('POINT(', T."start_station_longitude", ' ', T."start_station_latitude", ')')), ST_GEOGRAPHYFROMTEXT(CONCAT('POINT(', Z1."internal_point_lon", ' ', Z1."internal_point_lat", ')')))
    LEFT JOIN (
        SELECT DISTINCT ZG."zip_code", CZ."neighborhood", ZG."internal_point_lat", ZG."internal_point_lon"
        FROM "NEW_YORK_CITIBIKE_1"."GEO_US_BOUNDARIES"."ZIP_CODES" ZG
        JOIN "NEW_YORK_CITIBIKE_1"."CYCLISTIC"."ZIP_CODES" CZ
        ON TO_NUMBER(ZG."zip_code") = CZ."zip"
    ) Z2
    ON ST_WITHIN(ST_GEOGRAPHYFROMTEXT(CONCAT('POINT(', T."end_station_longitude", ' ', T."end_station_latitude", ')')), ST_GEOGRAPHYFROMTEXT(CONCAT('POINT(', Z2."internal_point_lon", ' ', Z2."internal_point_lat", ')')))
    WHERE YEAR(TO_TIMESTAMP(T."starttime" / 1000000)) = 2014
),
weather_data AS (
    -- Filter weather information for the Central Park station in 2014.
    SELECT
        TO_DATE(CONCAT("year", '-', "mo", '-', "da")) AS "weather_date",
        "temp",
        ("wdsp" * 0.5144) AS "wdsp_mps", -- Convert wind speed from knots to meters/second.
        ("prcp" * 2.54) AS "prcp_cm", -- Convert precipitation from inches to centimeters.
        "stn"
    FROM "NEW_YORK_CITIBIKE_1"."NOAA_GSOD"."GSOD2014"
    WHERE "stn" = '725030'
),
combined_data AS (
    -- Join neighborhood data and weather data on trip_date = weather_date.
    SELECT 
        NM."start_neighborhood",
        NM."end_neighborhood",
        NM."tripduration",
        W."temp",
        W."wdsp_mps",
        W."prcp_cm",
        EXTRACT(MONTH FROM NM."trip_date") AS "trip_month"
    FROM neighborhood_mapping NM
    LEFT JOIN weather_data W
    ON NM."trip_date" = W."weather_date"
),
trip_summary AS (
    -- Aggregate data to calculate the required metrics.
    SELECT 
        "start_neighborhood",
        "end_neighborhood",
        COUNT(*) AS "total_trips",
        ROUND(AVG("tripduration") / 60, 1) AS "avg_trip_duration_minutes", -- Convert seconds to minutes.
        ROUND(AVG("temp"), 1) AS "avg_temp_start_trip", 
        ROUND(AVG("wdsp_mps"), 1) AS "avg_wind_speed_start_trip",
        ROUND(AVG("prcp_cm"), 1) AS "avg_precipitation_start_trip",
        "trip_month"
    FROM combined_data
    GROUP BY "start_neighborhood", "end_neighborhood", "trip_month"
),
most_popular_month AS (
    -- Identify the most popular month for each start and end neighborhood pair.
    SELECT 
        "start_neighborhood",
        "end_neighborhood",
        "trip_month",
        RANK() OVER (PARTITION BY "start_neighborhood", "end_neighborhood" ORDER BY COUNT(*) DESC) AS "rank"
    FROM trip_summary
    GROUP BY "start_neighborhood", "end_neighborhood", "trip_month"
)
SELECT 
    TS."start_neighborhood",
    TS."end_neighborhood",
    SUM(TS."total_trips") AS "total_trips",
    ROUND(AVG(TS."avg_trip_duration_minutes"), 1) AS "avg_trip_duration_minutes",
    ROUND(AVG(TS."avg_temp_start_trip"), 1) AS "avg_temp_start_trip",
    ROUND(AVG(TS."avg_wind_speed_start_trip"), 1) AS "avg_wind_speed_start_trip",
    ROUND(AVG(TS."avg_precipitation_start_trip"), 1) AS "avg_precipitation_start_trip",
    MAX(MPM."trip_month") AS "most_popular_month"
FROM trip_summary TS
LEFT JOIN most_popular_month MPM
ON TS."start_neighborhood" = MPM."start_neighborhood"
   AND TS."end_neighborhood" = MPM."end_neighborhood"
   AND MPM."rank" = 1
GROUP BY TS."start_neighborhood", TS."end_neighborhood"
ORDER BY "total_trips" DESC NULLS LAST;