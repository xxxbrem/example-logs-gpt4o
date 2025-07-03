SELECT z."zip_code", COUNT(t."event_id") AS "hail_event_count"
FROM (
    SELECT "event_id", "event_latitude", "event_longitude"
    FROM NOAA_DATA_PLUS.NOAA_HISTORIC_SEVERE_STORMS.STORMS_2013
    UNION ALL
    SELECT "event_id", "event_latitude", "event_longitude"
    FROM NOAA_DATA_PLUS.NOAA_HISTORIC_SEVERE_STORMS.STORMS_2014
    UNION ALL
    SELECT "event_id", "event_latitude", "event_longitude"
    FROM NOAA_DATA_PLUS.NOAA_HISTORIC_SEVERE_STORMS.STORMS_2015
    UNION ALL
    SELECT "event_id", "event_latitude", "event_longitude"
    FROM NOAA_DATA_PLUS.NOAA_HISTORIC_SEVERE_STORMS.STORMS_2016
    UNION ALL
    SELECT "event_id", "event_latitude", "event_longitude"
    FROM NOAA_DATA_PLUS.NOAA_HISTORIC_SEVERE_STORMS.STORMS_2017
    UNION ALL
    SELECT "event_id", "event_latitude", "event_longitude"
    FROM NOAA_DATA_PLUS.NOAA_HISTORIC_SEVERE_STORMS.STORMS_2018
    UNION ALL
    SELECT "event_id", "event_latitude", "event_longitude"
    FROM NOAA_DATA_PLUS.NOAA_HISTORIC_SEVERE_STORMS.STORMS_2019
    UNION ALL
    SELECT "event_id", "event_latitude", "event_longitude"
    FROM NOAA_DATA_PLUS.NOAA_HISTORIC_SEVERE_STORMS.STORMS_2020
    UNION ALL
    SELECT "event_id", "event_latitude", "event_longitude"
    FROM NOAA_DATA_PLUS.NOAA_HISTORIC_SEVERE_STORMS.STORMS_2021
    UNION ALL
    SELECT "event_id", "event_latitude", "event_longitude"
    FROM NOAA_DATA_PLUS.NOAA_HISTORIC_SEVERE_STORMS.STORMS_2022
    UNION ALL
    SELECT "event_id", "event_latitude", "event_longitude"
    FROM NOAA_DATA_PLUS.NOAA_HISTORIC_SEVERE_STORMS.STORMS_2023
    UNION ALL
    SELECT "event_id", "event_latitude", "event_longitude"
    FROM NOAA_DATA_PLUS.NOAA_HISTORIC_SEVERE_STORMS.STORMS_2024
) t
JOIN NOAA_DATA_PLUS.GEO_US_BOUNDARIES.ZIP_CODES z
ON ST_WITHIN(ST_POINT(t."event_longitude", t."event_latitude"), TO_GEOGRAPHY(z."zip_code_geom"))
GROUP BY z."zip_code"
ORDER BY "hail_event_count" DESC NULLS LAST
LIMIT 5;