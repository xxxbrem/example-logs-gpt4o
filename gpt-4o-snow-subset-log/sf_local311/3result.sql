SELECT 
    combined."constructor_id", 
    c."name" AS "constructor_name", 
    r."year", 
    MAX(combined."total_combined_points") AS "peak_combined_points"
FROM (
    SELECT 
        r."constructor_id", 
        r."race_id", 
        MAX(r."points") AS "driver_points", 
        cs."points" AS "team_points",
        (MAX(r."points") + cs."points") AS "total_combined_points"
    FROM F1.F1.RESULTS r
    JOIN F1.F1.CONSTRUCTOR_STANDINGS cs 
        ON r."race_id" = cs."race_id" 
        AND r."constructor_id" = cs."constructor_id"
    GROUP BY r."constructor_id", r."race_id", cs."points"
) combined
JOIN F1.F1.CONSTRUCTORS c 
    ON combined."constructor_id" = c."constructor_id"
JOIN F1.F1.RACES r 
    ON combined."race_id" = r."race_id"
GROUP BY combined."constructor_id", c."name", r."year"
ORDER BY "peak_combined_points" DESC NULLS LAST
LIMIT 3;