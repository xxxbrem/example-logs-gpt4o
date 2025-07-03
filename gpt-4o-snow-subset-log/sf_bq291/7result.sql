WITH CreationTimeCheck AS (
    -- Confirm the presence of forecast creation dates in July 2019
    SELECT 
        DISTINCT DATE(TO_TIMESTAMP_NTZ(t."creation_time" / 1e6)) AS "creation_date"
    FROM "NOAA_GLOBAL_FORECAST_SYSTEM"."NOAA_GLOBAL_FORECAST_SYSTEM"."NOAA_GFS0P25" t
    WHERE YEAR(TO_TIMESTAMP_NTZ(t."creation_time" / 1e6)) = 2019
      AND MONTH(TO_TIMESTAMP_NTZ(t."creation_time" / 1e6)) = 7
),
FilteredForecasts AS (
    -- Retrieve forecasts created in July 2019 and compute geospatial distance
    SELECT
        t."forecast",
        DATEADD(DAY, 1, DATE(TO_TIMESTAMP_NTZ(t."creation_time" / 1e6))) AS "forecast_date",
        ST_DISTANCE(
            ST_POINT(51.5, 26.75),
            ST_GEOGFROMWKB(t."geography")
        ) / 1000 AS "distance_km"  -- Convert distance to kilometers
    FROM "NOAA_GLOBAL_FORECAST_SYSTEM"."NOAA_GLOBAL_FORECAST_SYSTEM"."NOAA_GFS0P25" t
    WHERE YEAR(TO_TIMESTAMP_NTZ(t."creation_time" / 1e6)) = 2019
      AND MONTH(TO_TIMESTAMP_NTZ(t."creation_time" / 1e6)) = 7
),
RelevantForecasts AS (
    -- Remove distance restriction temporarily for debugging
    SELECT *
    FROM FilteredForecasts
),
ExplodedForecasts AS (
    -- Flatten the forecast JSON structure to examine key fields
    SELECT
        r."forecast_date",
        f.value:"hours"::NUMBER AS "hours",
        f.value:"temperature_2m_above_ground"::FLOAT AS "temperature",
        f.value:"total_precipitation_surface"::FLOAT AS "precipitation",
        f.value:"total_cloud_cover_entire_atmosphere"::FLOAT AS "cloud_cover"
    FROM RelevantForecasts r,
         LATERAL FLATTEN(input => r."forecast") f
),
DailySummary AS (
    -- Aggregate metrics by forecast date for debugging
    SELECT
        "forecast_date",
        MAX("temperature") AS "max_temperature",
        MIN("temperature") AS "min_temperature",
        AVG("temperature") AS "avg_temperature",
        COALESCE(SUM("precipitation"), 0) AS "total_precipitation",
        COALESCE(AVG(CASE WHEN "hours" >= 10 AND "hours" <= 17 THEN "cloud_cover" END), 0) AS "avg_cloud_cover_10AM_5PM",
        -- Calculate total snowfall and rainfall
        COALESCE(SUM(CASE WHEN "temperature" < 32 THEN "precipitation" ELSE 0 END), 0) AS "total_snowfall",
        COALESCE(SUM(CASE WHEN "temperature" >= 32 THEN "precipitation" ELSE 0 END), 0) AS "total_rainfall"
    FROM ExplodedForecasts
    GROUP BY "forecast_date"
)
-- Final result
SELECT 
    "forecast_date",
    "max_temperature",
    "min_temperature",
    "avg_temperature",
    "total_precipitation",
    "avg_cloud_cover_10AM_5PM",
    "total_snowfall",
    "total_rainfall"
FROM DailySummary
ORDER BY "forecast_date";