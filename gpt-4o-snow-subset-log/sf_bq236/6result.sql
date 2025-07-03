SELECT z."zip_code", z."state_code", COUNT(s."event_id") AS "hail_event_count"
FROM "NOAA_DATA_PLUS"."GEO_US_BOUNDARIES"."ZIP_CODES" z
JOIN (
    SELECT "event_id", "event_point"
    FROM (
        SELECT "event_id", "event_point" 
        FROM "NOAA_DATA_PLUS"."NOAA_HISTORIC_SEVERE_STORMS"."STORMS_2013"
        UNION ALL
        SELECT "event_id", "event_point" 
        FROM "NOAA_DATA_PLUS"."NOAA_HISTORIC_SEVERE_STORMS"."STORMS_2014"
        UNION ALL
        SELECT "event_id", "event_point" 
        FROM "NOAA_DATA_PLUS"."NOAA_HISTORIC_SEVERE_STORMS"."STORMS_2015"
        UNION ALL
        SELECT "event_id", "event_point" 
        FROM "NOAA_DATA_PLUS"."NOAA_HISTORIC_SEVERE_STORMS"."STORMS_2016"
        UNION ALL
        SELECT "event_id", "event_point" 
        FROM "NOAA_DATA_PLUS"."NOAA_HISTORIC_SEVERE_STORMS"."STORMS_2017"
        UNION ALL
        SELECT "event_id", "event_point" 
        FROM "NOAA_DATA_PLUS"."NOAA_HISTORIC_SEVERE_STORMS"."STORMS_2018"
        UNION ALL
        SELECT "event_id", "event_point" 
        FROM "NOAA_DATA_PLUS"."NOAA_HISTORIC_SEVERE_STORMS"."STORMS_2019"
        UNION ALL
        SELECT "event_id", "event_point" 
        FROM "NOAA_DATA_PLUS"."NOAA_HISTORIC_SEVERE_STORMS"."STORMS_2020"
        UNION ALL
        SELECT "event_id", "event_point" 
        FROM "NOAA_DATA_PLUS"."NOAA_HISTORIC_SEVERE_STORMS"."STORMS_2021"
        UNION ALL
        SELECT "event_id", "event_point" 
        FROM "NOAA_DATA_PLUS"."NOAA_HISTORIC_SEVERE_STORMS"."STORMS_2022"
        UNION ALL
        SELECT "event_id", "event_point" 
        FROM "NOAA_DATA_PLUS"."NOAA_HISTORIC_SEVERE_STORMS"."STORMS_2023"
    ) 
    WHERE "event_point" IS NOT NULL
) s
ON ST_WITHIN(
    ST_GEOGRAPHYFROMWKB(s."event_point"), -- Convert hail event point from BINARY to GEOGRAPHY.
    ST_GEOGRAPHYFROMWKB(z."zip_code_geom") -- Convert ZIP code geometry from BINARY to GEOGRAPHY.
)
GROUP BY z."zip_code", z."state_code"
ORDER BY "hail_event_count" DESC NULLS LAST
LIMIT 5;