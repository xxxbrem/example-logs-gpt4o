WITH CombinedPoints AS (
    SELECT 
        r."year", 
        c."constructor_id", 
        c."points" AS "team_points", 
        MAX(s."points") AS "best_driver_points", 
        (c."points" + MAX(s."points")) AS "combined_points"
    FROM 
        "F1"."F1"."CONSTRUCTOR_STANDINGS" c
    JOIN 
        "F1"."F1"."DRIVER_STANDINGS" s
    ON 
        c."race_id" = s."race_id"
    JOIN 
        "F1"."F1"."RACES_EXT" r
    ON 
        c."race_id" = r."race_id"
    GROUP BY 
        r."year", c."constructor_id", c."points"
),
ConstructorNames AS (
    SELECT 
        "constructor_id", 
        "name" 
    FROM 
        "F1"."F1"."CONSTRUCTORS"
),
Top3CombinedPoints AS (
    SELECT 
        cp."year", 
        cn."name" AS "constructor_name", 
        cp."combined_points"
    FROM 
        CombinedPoints cp
    JOIN 
        ConstructorNames cn
    ON 
        cp."constructor_id" = cn."constructor_id"
    ORDER BY 
        cp."combined_points" DESC NULLS LAST
    LIMIT 3
)
SELECT 
    "constructor_name", 
    "year", 
    "combined_points"
FROM 
    Top3CombinedPoints
ORDER BY 
    "combined_points" DESC NULLS LAST;