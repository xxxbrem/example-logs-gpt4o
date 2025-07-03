WITH DriverLeaderboard AS (
    SELECT r."year", ds."driver_id", SUM(ds."points") AS "total_points"
    FROM "F1"."F1"."DRIVER_STANDINGS" ds
    JOIN "F1"."F1"."RACES" r ON ds."race_id" = r."race_id"
    GROUP BY r."year", ds."driver_id"
),
TopDriver AS (
    SELECT dl."year", dl."total_points", d."full_name" AS "driver_name"
    FROM DriverLeaderboard dl
    JOIN "F1"."F1"."DRIVERS" d ON dl."driver_id" = d."driver_id"
    QUALIFY ROW_NUMBER() OVER (PARTITION BY dl."year" ORDER BY dl."total_points" DESC NULLS LAST) = 1
),
ConstructorLeaderboard AS (
    SELECT r."year", cr."constructor_id", SUM(cr."points") AS "total_points"
    FROM "F1"."F1"."CONSTRUCTOR_RESULTS" cr
    JOIN "F1"."F1"."RACES" r ON cr."race_id" = r."race_id"
    GROUP BY r."year", cr."constructor_id"
),
TopConstructor AS (
    SELECT cl."year", cl."total_points", c."name" AS "constructor_name"
    FROM ConstructorLeaderboard cl
    JOIN "F1"."F1"."CONSTRUCTORS" c ON cl."constructor_id" = c."constructor_id"
    QUALIFY ROW_NUMBER() OVER (PARTITION BY cl."year" ORDER BY cl."total_points" DESC NULLS LAST) = 1
)
SELECT td."year", td."driver_name", td."total_points" AS "driver_points", 
       tc."constructor_name", tc."total_points" AS "constructor_points"
FROM TopDriver td
JOIN TopConstructor tc ON td."year" = tc."year"
ORDER BY td."year"
LIMIT 20;