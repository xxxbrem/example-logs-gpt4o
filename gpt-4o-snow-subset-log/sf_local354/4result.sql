SELECT 
    d."full_name", 
    d."nationality", 
    c."name" AS "constructor_name", 
    t3."year"
FROM (
    -- Subquery to filter drivers who had the same constructor in the first and last race of the season
    SELECT 
        t1."driver_id", 
        t1."constructor_id", 
        t1."year"
    FROM (
        SELECT "driver_id", "constructor_id", "year"
        FROM "F1"."F1"."DRIVES"
        WHERE "year" BETWEEN 1950 AND 1959 AND "is_first_drive_of_season" = 1
    ) t1
    JOIN (
        SELECT "driver_id", "constructor_id", "year"
        FROM "F1"."F1"."DRIVES"
        WHERE "year" BETWEEN 1950 AND 1959 AND "is_final_drive_of_season" = 1
    ) t2
    ON t1."driver_id" = t2."driver_id" AND t1."year" = t2."year"
    WHERE t1."constructor_id" = t2."constructor_id"
) t3
-- Join with the RACES table to ensure participation in at least two distinct rounds within the season
JOIN "F1"."F1"."RACES" r
ON t3."year" = r."year"
JOIN (
    SELECT "driver_id", "year", COUNT(DISTINCT "first_round") AS "distinct_rounds"
    FROM "F1"."F1"."DRIVES"
    WHERE "year" BETWEEN 1950 AND 1959
    GROUP BY "driver_id", "year"
    HAVING COUNT(DISTINCT "first_round") >= 2
) t4
ON t3."driver_id" = t4."driver_id" AND t3."year" = t4."year"
-- Join with DRIVERS table for driver details
JOIN "F1"."F1"."DRIVERS" d
ON t3."driver_id" = d."driver_id"
-- Join with CONSTRUCTORS table for constructor details
JOIN "F1"."F1"."CONSTRUCTORS" c
ON t3."constructor_id" = c."constructor_id"
LIMIT 20;