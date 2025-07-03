WITH DriverPoints AS (
    SELECT 
        r."year",
        ds."driver_id",
        SUM(ds."points" + COALESCE(sr."points", 0)) AS "total_points"
    FROM F1.F1.RACES r
    JOIN F1.F1.DRIVER_STANDINGS ds
        ON r."race_id" = ds."race_id"
    LEFT JOIN F1.F1.SPRINT_RESULTS sr
        ON sr."race_id" = r."race_id" AND sr."driver_id" = ds."driver_id"
    GROUP BY r."year", ds."driver_id"
),
BestDriver AS (
    SELECT 
        dp."year",
        d."full_name" AS "best_driver",
        dp."total_points" AS "driver_points"
    FROM DriverPoints dp
    JOIN F1.F1.DRIVERS d
        ON dp."driver_id" = d."driver_id"
    QUALIFY ROW_NUMBER() OVER (PARTITION BY dp."year" ORDER BY dp."total_points" DESC NULLS LAST) = 1
),
ConstructorPoints AS (
    SELECT 
        r."year",
        cs."constructor_id",
        SUM(cs."points") AS "total_points"
    FROM F1.F1.RACES r
    JOIN F1.F1.CONSTRUCTOR_STANDINGS cs
        ON r."race_id" = cs."race_id"
    GROUP BY r."year", cs."constructor_id"
),
BestConstructor AS (
    SELECT 
        cp."year",
        c."name" AS "best_constructor",
        cp."total_points" AS "constructor_points"
    FROM ConstructorPoints cp
    JOIN F1.F1.CONSTRUCTORS c
        ON cp."constructor_id" = c."constructor_id"
    QUALIFY ROW_NUMBER() OVER (PARTITION BY cp."year" ORDER BY cp."total_points" DESC NULLS LAST) = 1
)
SELECT 
    bd."year",
    bd."best_driver",
    bc."best_constructor"
FROM BestDriver bd
JOIN BestConstructor bc
    ON bd."year" = bc."year"
ORDER BY bd."year";