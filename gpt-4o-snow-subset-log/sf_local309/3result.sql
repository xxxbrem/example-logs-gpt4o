WITH driver_points_per_year AS (
    SELECT 
        r."year", 
        res."driver_id", 
        SUM(res."points") AS "total_points",
        ROW_NUMBER() OVER (PARTITION BY r."year" ORDER BY SUM(res."points") DESC) AS "rank"
    FROM "F1"."F1"."RESULTS" res
    JOIN "F1"."F1"."RACES" r ON res."race_id" = r."race_id"
    GROUP BY r."year", res."driver_id"
),
constructor_points_per_year AS (
    SELECT 
        r."year", 
        res."constructor_id", 
        SUM(res."points") AS "total_points",
        ROW_NUMBER() OVER (PARTITION BY r."year" ORDER BY SUM(res."points") DESC) AS "rank"
    FROM "F1"."F1"."RESULTS" res
    JOIN "F1"."F1"."RACES" r ON res."race_id" = r."race_id"
    GROUP BY r."year", res."constructor_id"
),
max_driver_points_per_year AS (
    SELECT "year", "driver_id", "total_points"
    FROM driver_points_per_year
    WHERE "rank" = 1
),
max_constructor_points_per_year AS (
    SELECT "year", "constructor_id", "total_points"
    FROM constructor_points_per_year
    WHERE "rank" = 1
)
SELECT 
    drivers."full_name" AS "driver_full_name", 
    constructors."name" AS "constructor_name", 
    max_driver_points_per_year."year",
    max_driver_points_per_year."total_points" AS "driver_points",
    max_constructor_points_per_year."total_points" AS "constructor_points"
FROM max_driver_points_per_year
JOIN max_constructor_points_per_year ON max_driver_points_per_year."year" = max_constructor_points_per_year."year"
JOIN "F1"."F1"."DRIVERS" drivers ON drivers."driver_id" = max_driver_points_per_year."driver_id"
JOIN "F1"."F1"."CONSTRUCTORS" constructors ON constructors."constructor_id" = max_constructor_points_per_year."constructor_id"
ORDER BY max_driver_points_per_year."year";