WITH hail_event_locations AS (
    SELECT DISTINCT 
        "cz_name",
        "state",
        ROUND("event_latitude", 2) AS "latitude",
        ROUND("event_longitude", 2) AS "longitude"
    FROM (
        SELECT "cz_name", "state", "event_latitude", "event_longitude"
        FROM "NOAA_DATA_PLUS"."NOAA_HISTORIC_SEVERE_STORMS"."STORMS_2013"
        WHERE "event_type" ILIKE '%hail%'
        
        UNION ALL
        
        SELECT "cz_name", "state", "event_latitude", "event_longitude"
        FROM "NOAA_DATA_PLUS"."NOAA_HISTORIC_SEVERE_STORMS"."STORMS_2014"
        WHERE "event_type" ILIKE '%hail%'
        
        UNION ALL

        SELECT "cz_name", "state", "event_latitude", "event_longitude"
        FROM "NOAA_DATA_PLUS"."NOAA_HISTORIC_SEVERE_STORMS"."STORMS_2015"
        WHERE "event_type" ILIKE '%hail%'

        UNION ALL

        SELECT "cz_name", "state", "event_latitude", "event_longitude"
        FROM "NOAA_DATA_PLUS"."NOAA_HISTORIC_SEVERE_STORMS"."STORMS_2016"
        WHERE "event_type" ILIKE '%hail%'

        UNION ALL

        SELECT "cz_name", "state", "event_latitude", "event_longitude"
        FROM "NOAA_DATA_PLUS"."NOAA_HISTORIC_SEVERE_STORMS"."STORMS_2017"
        WHERE "event_type" ILIKE '%hail%'

        UNION ALL

        SELECT "cz_name", "state", "event_latitude", "event_longitude"
        FROM "NOAA_DATA_PLUS"."NOAA_HISTORIC_SEVERE_STORMS"."STORMS_2018"
        WHERE "event_type" ILIKE '%hail%'

        UNION ALL

        SELECT "cz_name", "state", "event_latitude", "event_longitude"
        FROM "NOAA_DATA_PLUS"."NOAA_HISTORIC_SEVERE_STORMS"."STORMS_2019"
        WHERE "event_type" ILIKE '%hail%'

        UNION ALL

        SELECT "cz_name", "state", "event_latitude", "event_longitude"
        FROM "NOAA_DATA_PLUS"."NOAA_HISTORIC_SEVERE_STORMS"."STORMS_2020"
        WHERE "event_type" ILIKE '%hail%'

        UNION ALL

        SELECT "cz_name", "state", "event_latitude", "event_longitude"
        FROM "NOAA_DATA_PLUS"."NOAA_HISTORIC_SEVERE_STORMS"."STORMS_2021"
        WHERE "event_type" ILIKE '%hail%'

        UNION ALL

        SELECT "cz_name", "state", "event_latitude", "event_longitude"
        FROM "NOAA_DATA_PLUS"."NOAA_HISTORIC_SEVERE_STORMS"."STORMS_2022"
        WHERE "event_type" ILIKE '%hail%'

        UNION ALL

        SELECT "cz_name", "state", "event_latitude", "event_longitude"
        FROM "NOAA_DATA_PLUS"."NOAA_HISTORIC_SEVERE_STORMS"."STORMS_2023"
        WHERE "event_type" ILIKE '%hail%'
    )
),
zip_match AS (
    SELECT 
        h."cz_name",
        h."state",
        z."zip_code",
        COUNT(*) AS "hail_event_count"
    FROM hail_event_locations h
    LEFT JOIN "NOAA_DATA_PLUS"."GEO_US_BOUNDARIES"."ZIP_CODES" z
    ON ST_WITHIN(
        ST_MAKEPOINT(h."longitude", h."latitude"), 
        ST_GEOGFROMWKB(z."zip_code_geom")
    )
    GROUP BY h."cz_name", h."state", z."zip_code"
)
SELECT 
    "zip_code", 
    SUM("hail_event_count") AS "total_hail_event_count"
FROM zip_match 
WHERE "zip_code" IS NOT NULL
GROUP BY "zip_code"
ORDER BY "total_hail_event_count" DESC NULLS LAST
LIMIT 5;