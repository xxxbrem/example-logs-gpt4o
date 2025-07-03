SELECT 
    d."driver_id", 
    d_ext."full_name", 
    c."name" AS "constructor_name", 
    d."year", 
    MIN(d."first_round") AS "first_round", 
    MAX(d."last_round") AS "last_round", 
    (MAX(d."last_round") - MIN(d."first_round") + 1) AS "total_race_rounds"
FROM F1.F1.DRIVES AS d
JOIN F1.F1.CONSTRUCTORS AS c 
    ON d."constructor_id" = c."constructor_id"
JOIN F1.F1.DRIVERS_EXT AS d_ext
    ON d."driver_id" = d_ext."driver_id"
WHERE d."year" BETWEEN 1950 AND 1959
AND d."constructor_id" IS NOT NULL
GROUP BY 
    d."driver_id", 
    d."year", 
    c."name", 
    d_ext."full_name"
HAVING COUNT(DISTINCT d."constructor_id") = 1
AND (MAX(d."last_round") - MIN(d."first_round") + 1) >= 2
ORDER BY d."year", d."driver_id";