WITH hailstorm_events AS (
    SELECT 
        "cz_name" AS "county",
        COUNT(*) AS "hail_events_count"
    FROM (
        SELECT "state", "cz_name"
        FROM NOAA_DATA_PLUS.NOAA_HISTORIC_SEVERE_STORMS.STORMS_2013
        WHERE "event_type" ILIKE '%hail%'
        UNION ALL
        SELECT "state", "cz_name"
        FROM NOAA_DATA_PLUS.NOAA_HISTORIC_SEVERE_STORMS.STORMS_2014
        WHERE "event_type" ILIKE '%hail%'
        UNION ALL
        SELECT "state", "cz_name"
        FROM NOAA_DATA_PLUS.NOAA_HISTORIC_SEVERE_STORMS.STORMS_2015
        WHERE "event_type" ILIKE '%hail%'
        UNION ALL
        SELECT "state", "cz_name"
        FROM NOAA_DATA_PLUS.NOAA_HISTORIC_SEVERE_STORMS.STORMS_2016
        WHERE "event_type" ILIKE '%hail%'
        UNION ALL
        SELECT "state", "cz_name"
        FROM NOAA_DATA_PLUS.NOAA_HISTORIC_SEVERE_STORMS.STORMS_2017
        WHERE "event_type" ILIKE '%hail%'
        UNION ALL
        SELECT "state", "cz_name"
        FROM NOAA_DATA_PLUS.NOAA_HISTORIC_SEVERE_STORMS.STORMS_2018
        WHERE "event_type" ILIKE '%hail%'
        UNION ALL
        SELECT "state", "cz_name"
        FROM NOAA_DATA_PLUS.NOAA_HISTORIC_SEVERE_STORMS.STORMS_2019
        WHERE "event_type" ILIKE '%hail%'
        UNION ALL
        SELECT "state", "cz_name"
        FROM NOAA_DATA_PLUS.NOAA_HISTORIC_SEVERE_STORMS.STORMS_2020
        WHERE "event_type" ILIKE '%hail%'
        UNION ALL
        SELECT "state", "cz_name"
        FROM NOAA_DATA_PLUS.NOAA_HISTORIC_SEVERE_STORMS.STORMS_2021
        WHERE "event_type" ILIKE '%hail%'
        UNION ALL
        SELECT "state", "cz_name"
        FROM NOAA_DATA_PLUS.NOAA_HISTORIC_SEVERE_STORMS.STORMS_2022
        WHERE "event_type" ILIKE '%hail%'
        UNION ALL
        SELECT "state", "cz_name"
        FROM NOAA_DATA_PLUS.NOAA_HISTORIC_SEVERE_STORMS.STORMS_2023
        WHERE "event_type" ILIKE '%hail%'
    ) hail_combined
    GROUP BY "cz_name"
),
zip_hail_counts AS (
    SELECT 
        zip."zip_code",
        zip."county",
        zip."state_code",
        hail."hail_events_count"
    FROM NOAA_DATA_PLUS.GEO_US_BOUNDARIES.ZIP_CODES zip
    JOIN hailstorm_events hail
        ON zip."county" ILIKE hail."county"
    WHERE hail."hail_events_count" IS NOT NULL
)
SELECT 
    "zip_code",
    SUM("hail_events_count") AS "total_hail_events"
FROM zip_hail_counts
GROUP BY "zip_code"
ORDER BY "total_hail_events" DESC NULLS LAST
LIMIT 5;