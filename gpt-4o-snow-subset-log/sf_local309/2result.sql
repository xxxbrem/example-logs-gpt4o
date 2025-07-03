WITH top_driver_per_year AS (
    SELECT 
        r."year", 
        ds."driver_id",
        SUM(ds."points") AS "total_driver_points",
        RANK() OVER (PARTITION BY r."year" ORDER BY SUM(ds."points") DESC NULLS LAST) AS "rank"
    FROM "F1"."F1"."DRIVER_STANDINGS" ds
    JOIN "F1"."F1"."RACES" r 
        ON ds."race_id" = r."race_id"
    GROUP BY r."year", ds."driver_id"
),
top_constructor_per_year AS (
    SELECT 
        r."year", 
        cr."constructor_id",
        SUM(cr."points") AS "total_constructor_points",
        RANK() OVER (PARTITION BY r."year" ORDER BY SUM(cr."points") DESC NULLS LAST) AS "rank"
    FROM "F1"."F1"."CONSTRUCTOR_RESULTS" cr
    JOIN "F1"."F1"."RACES" r 
        ON cr."race_id" = r."race_id"
    GROUP BY r."year", cr."constructor_id"
),
top_driver_details AS (
    SELECT 
        t."year",
        d."full_name" AS "driver_full_name"
    FROM top_driver_per_year t
    JOIN "F1"."F1"."DRIVERS_EXT" d 
        ON t."driver_id" = d."driver_id"
    WHERE t."rank" = 1
),
top_constructor_details AS (
    SELECT 
        t."year",
        c."name" AS "constructor_name"
    FROM top_constructor_per_year t
    JOIN "F1"."F1"."CONSTRUCTORS" c 
        ON t."constructor_id" = c."constructor_id"
    WHERE t."rank" = 1
)
SELECT 
    d."year",
    d."driver_full_name",
    c."constructor_name"
FROM top_driver_details d
JOIN top_constructor_details c 
    ON d."year" = c."year"
ORDER BY d."year" ASC;