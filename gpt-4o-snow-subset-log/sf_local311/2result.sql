SELECT 
    c."constructor_id", 
    c."name" AS "constructor_name", 
    cc."year", 
    cc."combined_points"
FROM (
    SELECT 
        cr."constructor_id", 
        r."year", 
        SUM(dr."points" + cr."points") AS "combined_points"
    FROM F1.F1.CONSTRUCTOR_RESULTS cr
    JOIN F1.F1.RESULTS dr
        ON cr."constructor_id" = dr."constructor_id" 
        AND cr."race_id" = dr."race_id"
    JOIN F1.F1.RACES_EXT r
        ON cr."race_id" = r."race_id"
    GROUP BY cr."constructor_id", r."year"
) cc
JOIN F1.F1.CONSTRUCTORS c
    ON cc."constructor_id" = c."constructor_id"
ORDER BY cc."combined_points" DESC NULLS LAST
LIMIT 3;