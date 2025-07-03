SELECT 
    constructors."name" AS "constructor_name",
    constructors."constructor_id",
    races."year",
    SUM(cs."points" + driver_summary."best_driver_points") AS "total_combined_points"
FROM F1.F1.CONSTRUCTOR_STANDINGS cs
JOIN F1.F1.RACES races
ON cs."race_id" = races."race_id"
JOIN F1.F1.CONSTRUCTORS constructors
ON cs."constructor_id" = constructors."constructor_id"
LEFT JOIN (
    SELECT 
        ds."race_id", 
        MAX(ds."points") AS "best_driver_points"
    FROM F1.F1.DRIVER_STANDINGS_EXT ds
    GROUP BY ds."race_id"
) AS driver_summary
ON cs."race_id" = driver_summary."race_id"
GROUP BY constructors."name", constructors."constructor_id", races."year"
ORDER BY "total_combined_points" DESC NULLS LAST
LIMIT 3;