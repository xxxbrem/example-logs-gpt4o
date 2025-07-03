WITH DRIVER_TOTAL_POINTS AS (
    SELECT 
        r."year",
        ds."driver_id",
        SUM(ds."points") AS "total_points"
    FROM 
        F1.F1.DRIVER_STANDINGS ds
    JOIN 
        F1.F1.RACES r
    ON 
        ds."race_id" = r."race_id"
    GROUP BY 
        r."year", ds."driver_id"
),
MAX_DRIVER_POINTS AS (
    SELECT 
        t."year",
        t."driver_id",
        t."total_points"
    FROM 
        DRIVER_TOTAL_POINTS t
    WHERE 
        t."total_points" = (SELECT MAX(inner_t."total_points")
                            FROM DRIVER_TOTAL_POINTS inner_t
                            WHERE inner_t."year" = t."year")
),
CONSTRUCTOR_TOTAL_POINTS AS (
    SELECT 
        r."year",
        cs."constructor_id",
        SUM(cs."points") AS "total_points"
    FROM 
        F1.F1.CONSTRUCTOR_STANDINGS cs
    JOIN 
        F1.F1.RACES r
    ON 
        cs."race_id" = r."race_id"
    GROUP BY 
        r."year", cs."constructor_id"
),
MAX_CONSTRUCTOR_POINTS AS (
    SELECT 
        t."year",
        t."constructor_id",
        t."total_points"
    FROM 
        CONSTRUCTOR_TOTAL_POINTS t
    WHERE 
        t."total_points" = (SELECT MAX(inner_t."total_points")
                            FROM CONSTRUCTOR_TOTAL_POINTS inner_t
                            WHERE inner_t."year" = t."year")
)
SELECT 
    mdp."year",
    d."full_name" AS "driver_name",
    mdp."total_points" AS "driver_total_points",
    c."name" AS "constructor_name",
    mcp."total_points" AS "constructor_total_points"
FROM 
    MAX_DRIVER_POINTS mdp
JOIN 
    F1.F1.DRIVERS d
ON 
    mdp."driver_id" = d."driver_id"
JOIN 
    MAX_CONSTRUCTOR_POINTS mcp
ON 
    mdp."year" = mcp."year"
JOIN 
    F1.F1.CONSTRUCTORS c
ON 
    mcp."constructor_id" = c."constructor_id"
ORDER BY 
    mdp."year";