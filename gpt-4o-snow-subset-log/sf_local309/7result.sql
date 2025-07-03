WITH driver_points AS (
    -- Step 1: Calculate the total points for each driver in each year.
    SELECT 
        r."year",
        ds."driver_id",
        SUM(ds."points") AS "total_points"
    FROM 
        F1.F1.DRIVER_STANDINGS ds
    JOIN 
        F1.F1.RACES r ON ds."race_id" = r."race_id"
    GROUP BY 
        r."year", ds."driver_id"
),
max_driver_points AS (
    -- Step 2: Identify the driver who scored the most points in each year.
    SELECT 
        "year",
        "driver_id",
        MAX("total_points") AS "max_points"
    FROM 
        driver_points
    GROUP BY 
        "year", "driver_id"
    QUALIFY ROW_NUMBER() OVER (PARTITION BY "year" ORDER BY "max_points" DESC NULLS LAST) = 1
),
constructor_points AS (
    -- Step 3: Calculate the total points for each constructor in each year.
    SELECT 
        r."year",
        cs."constructor_id",
        SUM(cs."points") AS "total_points"
    FROM 
        F1.F1.CONSTRUCTOR_STANDINGS cs
    JOIN 
        F1.F1.RACES r ON cs."race_id" = r."race_id"
    GROUP BY 
        r."year", cs."constructor_id"
),
max_constructor_points AS (
    -- Step 4: Identify the constructor that scored the most points in each year.
    SELECT 
        "year",
        "constructor_id",
        MAX("total_points") AS "max_points"
    FROM 
        constructor_points
    GROUP BY 
        "year", "constructor_id"
    QUALIFY ROW_NUMBER() OVER (PARTITION BY "year" ORDER BY "max_points" DESC NULLS LAST) = 1
)
SELECT 
    dp."year",
    drv."full_name" AS "driver_full_name",
    dp."max_points" AS "driver_total_points",
    cons."name" AS "constructor_name",
    cp."max_points" AS "constructor_total_points"
FROM 
    max_driver_points dp
JOIN 
    F1.F1.DRIVERS drv ON dp."driver_id" = drv."driver_id"
JOIN 
    max_constructor_points cp ON dp."year" = cp."year"
JOIN 
    F1.F1.CONSTRUCTORS cons ON cp."constructor_id" = cons."constructor_id"
ORDER BY 
    dp."year";