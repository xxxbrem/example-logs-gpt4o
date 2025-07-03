WITH RegionForecasts AS (
    SELECT 
        t."creation_time", 
        DATEADD(DAY, 1, TO_TIMESTAMP_NTZ(t."creation_time" / 1000000)) AS "forecast_date", 
        f.value::VARIANT:"temperature_2m_above_ground"::NUMBER AS "temperature",
        f.value::VARIANT:"total_precipitation_surface"::NUMBER AS "precipitation",
        f.value::VARIANT:"total_cloud_cover_entire_atmosphere"::NUMBER AS "cloud_cover",
        f.value::VARIANT:"hours"::NUMBER AS "hour",
        f.value::VARIANT:"time"::NUMBER AS "forecast_time"
    FROM 
        "NOAA_GLOBAL_FORECAST_SYSTEM"."NOAA_GLOBAL_FORECAST_SYSTEM"."NOAA_GFS0P25" t,
        LATERAL FLATTEN(input => t."forecast") f
    WHERE 
        t."creation_time" >= 1561939200000000 -- July 1, 2019
        AND t."creation_time" < 1564617600000000 -- August 1, 2019
        AND ST_DISTANCE(
            ST_POINT(26.75, 51.5), 
            TO_GEOGRAPHY(t."geography")
        ) <= 5000
),
DailySummaries AS (
    SELECT 
        "forecast_date",
        MAX("temperature") AS "max_temperature",
        MIN("temperature") AS "min_temperature",
        AVG("temperature") AS "avg_temperature",
        SUM("precipitation") AS "total_precipitation",
        AVG(CASE WHEN "hour" BETWEEN 10 AND 17 THEN "cloud_cover" END) AS "avg_cloud_cover",
        CASE 
            WHEN AVG("temperature") < 0 THEN SUM("precipitation") -- Total snowfall
            ELSE NULL 
        END AS "total_snowfall",
        CASE 
            WHEN AVG("temperature") >= 0 THEN SUM("precipitation") -- Total rainfall
            ELSE NULL
        END AS "total_rainfall"
    FROM 
        RegionForecasts
    GROUP BY 
        "forecast_date"
)
SELECT 
    "forecast_date",
    "max_temperature",
    "min_temperature",
    "avg_temperature",
    "total_precipitation",
    "avg_cloud_cover",
    "total_snowfall",
    "total_rainfall"
FROM 
    DailySummaries
ORDER BY 
    "forecast_date";