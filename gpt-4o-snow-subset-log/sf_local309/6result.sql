WITH DriverPointsByYear AS (
    SELECT 
        r."year",
        ds."driver_id",
        SUM(ds."points") AS total_driver_points
    FROM F1.F1.DRIVER_STANDINGS_EXT ds
    JOIN F1.F1.RACES r
        ON ds."race_id" = r."race_id"
    GROUP BY r."year", ds."driver_id"
),
ConstructorPointsByYear AS (
    SELECT 
        r."year",
        cs."constructor_id",
        SUM(cs."points") AS total_constructor_points
    FROM F1.F1.CONSTRUCTOR_STANDINGS cs
    JOIN F1.F1.RACES r
        ON cs."race_id" = r."race_id"
    GROUP BY r."year", cs."constructor_id"
),
MaxDriverPointsByYear AS (
    SELECT 
        "year",
        "driver_id",
        total_driver_points
    FROM (
        SELECT 
            "year", 
            "driver_id", 
            total_driver_points,
            RANK() OVER (PARTITION BY "year" ORDER BY total_driver_points DESC NULLS LAST) AS rank
        FROM DriverPointsByYear
    )
    WHERE rank = 1
),
MaxConstructorPointsByYear AS (
    SELECT 
        "year",
        "constructor_id",
        total_constructor_points
    FROM (
        SELECT 
            "year", 
            "constructor_id", 
            total_constructor_points,
            RANK() OVER (PARTITION BY "year" ORDER BY total_constructor_points DESC NULLS LAST) AS rank
        FROM ConstructorPointsByYear
    )
    WHERE rank = 1
)
SELECT 
    d."year",
    dr."full_name" AS driver_name,
    dr."driver_id",
    cons."name" AS constructor_name,
    cons."constructor_id"
FROM MaxDriverPointsByYear d
JOIN F1.F1.DRIVERS dr
    ON d."driver_id" = dr."driver_id"
JOIN MaxConstructorPointsByYear c
    ON d."year" = c."year"
JOIN F1.F1.CONSTRUCTORS cons
    ON c."constructor_id" = cons."constructor_id"
ORDER BY d."year";