SELECT 
    rs."year" AS "year",
    cns."name" AS "constructor_name",
    (cs."points" + COALESCE(MAX(ds."points"), 0)) AS "combined_points"
FROM F1.F1.CONSTRUCTOR_STANDINGS cs
LEFT JOIN F1.F1.DRIVER_STANDINGS ds
    ON cs."race_id" = ds."race_id" AND cs."constructor_id" = ds."driver_id"
INNER JOIN F1.F1.RACES rs
    ON cs."race_id" = rs."race_id"
INNER JOIN F1.F1.CONSTRUCTORS cns
    ON cs."constructor_id" = cns."constructor_id"
GROUP BY rs."year", cns."name", cs."points"
ORDER BY "combined_points" DESC NULLS LAST
LIMIT 3;