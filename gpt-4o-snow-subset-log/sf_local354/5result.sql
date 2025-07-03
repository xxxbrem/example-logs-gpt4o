SELECT 
    d."driver_id", 
    dr."full_name", 
    d."year", 
    c."name" AS "constructor_name", 
    COUNT(DISTINCT r."round") AS "distinct_rounds"
FROM 
    "F1"."F1"."DRIVES" d
JOIN 
    "F1"."F1"."CONSTRUCTORS" c 
    ON d."constructor_id" = c."constructor_id"
JOIN 
    "F1"."F1"."DRIVERS" dr 
    ON d."driver_id" = dr."driver_id"
JOIN 
    "F1"."F1"."RACES" r
    ON d."year" = r."year" 
    AND r."round" BETWEEN d."first_round" AND d."last_round"
WHERE 
    d."year" BETWEEN 1950 AND 1959
    AND d."constructor_id" IN (
        SELECT DISTINCT d_sub."constructor_id"
        FROM "F1"."F1"."DRIVES" d_sub
        WHERE d_sub."driver_id" = d."driver_id"
          AND d_sub."year" = d."year"
    )
GROUP BY 
    d."driver_id", dr."full_name", d."year", c."name"
HAVING 
    COUNT(DISTINCT r."round") > 1
ORDER BY 
    d."year", dr."full_name";