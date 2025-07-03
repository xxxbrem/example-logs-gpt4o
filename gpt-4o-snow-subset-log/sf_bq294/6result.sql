SELECT 
    t."trip_id", 
    t."duration_sec", 
    t."start_date", 
    t."start_station_name", 
    CONCAT(t."start_station_name", ' - ', t."end_station_name") AS "route", 
    t."bike_number", 
    t."subscriber_type", 
    t."member_birth_year", 
    (2023 - t."member_birth_year") AS "current_age", 
    CASE 
        WHEN (2023 - t."member_birth_year") < 40 THEN 'Young (<40 Y.O)'
        WHEN (2023 - t."member_birth_year") BETWEEN 40 AND 60 THEN 'Adult (40-60 Y.O)'
        ELSE 'Senior Adult (>60 Y.O)'
    END AS "age_classification", 
    t."member_gender", 
    r."name" AS "region_name"
FROM "SAN_FRANCISCO_PLUS"."SAN_FRANCISCO_BIKESHARE"."BIKESHARE_TRIPS" t
LEFT JOIN "SAN_FRANCISCO_PLUS"."SAN_FRANCISCO_BIKESHARE"."BIKESHARE_STATION_INFO" si
    ON t."start_station_name" = si."name"
LEFT JOIN "SAN_FRANCISCO_PLUS"."SAN_FRANCISCO_BIKESHARE"."BIKESHARE_REGIONS" r
    ON si."region_id" = r."region_id"
WHERE t."start_date" >= 1498867200000000 -- July 1, 2017
  AND t."start_date" <= 1514678400000000 -- December 31, 2017
  AND t."start_station_name" IS NOT NULL
  AND t."member_birth_year" IS NOT NULL
  AND t."member_gender" IS NOT NULL
ORDER BY t."duration_sec" DESC NULLS LAST
LIMIT 5;