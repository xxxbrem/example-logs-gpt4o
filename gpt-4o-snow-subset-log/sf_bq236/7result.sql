WITH hailstorm_events AS (
    SELECT 
        "cz_name" AS "county", 
        "state", 
        COUNT(*) AS "event_count"
    FROM (
        SELECT "cz_name", "state" FROM "NOAA_DATA_PLUS"."NOAA_HISTORIC_SEVERE_STORMS"."STORMS_2013" WHERE "event_type" ILIKE '%hail%'
        UNION ALL
        SELECT "cz_name", "state" FROM "NOAA_DATA_PLUS"."NOAA_HISTORIC_SEVERE_STORMS"."STORMS_2014" WHERE "event_type" ILIKE '%hail%'
        UNION ALL
        SELECT "cz_name", "state" FROM "NOAA_DATA_PLUS"."NOAA_HISTORIC_SEVERE_STORMS"."STORMS_2015" WHERE "event_type" ILIKE '%hail%'
        UNION ALL
        SELECT "cz_name", "state" FROM "NOAA_DATA_PLUS"."NOAA_HISTORIC_SEVERE_STORMS"."STORMS_2016" WHERE "event_type" ILIKE '%hail%'
        UNION ALL
        SELECT "cz_name", "state" FROM "NOAA_DATA_PLUS"."NOAA_HISTORIC_SEVERE_STORMS"."STORMS_2017" WHERE "event_type" ILIKE '%hail%'
        UNION ALL
        SELECT "cz_name", "state" FROM "NOAA_DATA_PLUS"."NOAA_HISTORIC_SEVERE_STORMS"."STORMS_2018" WHERE "event_type" ILIKE '%hail%'
        UNION ALL
        SELECT "cz_name", "state" FROM "NOAA_DATA_PLUS"."NOAA_HISTORIC_SEVERE_STORMS"."STORMS_2019" WHERE "event_type" ILIKE '%hail%'
        UNION ALL
        SELECT "cz_name", "state" FROM "NOAA_DATA_PLUS"."NOAA_HISTORIC_SEVERE_STORMS"."STORMS_2020" WHERE "event_type" ILIKE '%hail%'
        UNION ALL
        SELECT "cz_name", "state" FROM "NOAA_DATA_PLUS"."NOAA_HISTORIC_SEVERE_STORMS"."STORMS_2021" WHERE "event_type" ILIKE '%hail%'
        UNION ALL
        SELECT "cz_name", "state" FROM "NOAA_DATA_PLUS"."NOAA_HISTORIC_SEVERE_STORMS"."STORMS_2022" WHERE "event_type" ILIKE '%hail%'
        UNION ALL
        SELECT "cz_name", "state" FROM "NOAA_DATA_PLUS"."NOAA_HISTORIC_SEVERE_STORMS"."STORMS_2023" WHERE "event_type" ILIKE '%hail%'
    ) AS combined_storms
    GROUP BY "cz_name", "state"
),
top_hailstorm_areas AS (
    SELECT 
        h."county", 
        h."state", 
        g."zip_code",
        SUM(h."event_count") AS "total_event_count"
    FROM hailstorm_events h
    JOIN "NOAA_DATA_PLUS"."GEO_US_BOUNDARIES"."ZIP_CODES" g
    ON LOWER(h."county") LIKE CONCAT('%', LOWER(g."county"), '%') 
       AND LOWER(h."state") = LOWER(g."state_code")
    GROUP BY h."county", h."state", g."zip_code"
    ORDER BY "total_event_count" DESC NULLS LAST
)
SELECT "zip_code", "county", "state", "total_event_count"
FROM top_hailstorm_areas
WHERE "total_event_count" > 0
LIMIT 5;