SELECT 
    t1."year",
    t1."combined_points",
    c."short_name" AS "constructor_name"
FROM 
    (
        SELECT 
            t1."constructor_id",
            t1."year",
            (t1."best_driver_points" + t2."total_team_points") AS "combined_points"
        FROM 
            (
                SELECT 
                    t3."constructor_id",
                    t2."year",
                    MAX(t1."points") AS "best_driver_points"
                FROM 
                    "F1"."F1"."DRIVER_STANDINGS" t1
                JOIN 
                    "F1"."F1"."RACES" t2
                ON 
                    t1."race_id" = t2."race_id"
                JOIN 
                    "F1"."F1"."DRIVES" t3
                ON 
                    t1."driver_id" = t3."driver_id"
                AND 
                    t2."year" = t3."year"
                GROUP BY 
                    t3."constructor_id", t2."year"
            ) t1
        JOIN 
            (
                SELECT 
                    t1."constructor_id",
                    t2."year",
                    SUM(t1."points") AS "total_team_points"
                FROM 
                    "F1"."F1"."CONSTRUCTOR_STANDINGS" t1
                JOIN 
                    "F1"."F1"."RACES" t2
                ON 
                    t1."race_id" = t2."race_id"
                GROUP BY 
                    t1."constructor_id", t2."year"
            ) t2
        ON 
            t1."constructor_id" = t2."constructor_id"
        AND 
            t1."year" = t2."year"
    ) t1
JOIN 
    "F1"."F1"."CONSTRUCTORS_EXT" c
ON 
    t1."constructor_id" = c."constructor_id"
ORDER BY 
    t1."combined_points" DESC NULLS LAST
LIMIT 3;