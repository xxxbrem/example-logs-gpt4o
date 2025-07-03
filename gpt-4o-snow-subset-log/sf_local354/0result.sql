SELECT DISTINCT 
    d."driver_id", 
    dr."full_name", 
    d."year", 
    d."constructor_id", 
    c."name" AS "constructor_name"
FROM F1.F1.DRIVES d
INNER JOIN F1.F1.DRIVERS dr 
    ON d."driver_id" = dr."driver_id"
INNER JOIN F1.F1.CONSTRUCTORS c 
    ON d."constructor_id" = c."constructor_id"
WHERE d."year" BETWEEN 1950 AND 1959
  AND d."constructor_id" IN (
      SELECT "constructor_id"
      FROM F1.F1.DRIVES d_sub
      WHERE d_sub."driver_id" = d."driver_id"
        AND d_sub."year" = d."year"
        AND d_sub."first_round" = d."first_round"
    )
  AND d."constructor_id" IN (
      SELECT "constructor_id"
      FROM F1.F1.DRIVES d_sub
      WHERE d_sub."driver_id" = d."driver_id"
        AND d_sub."year" = d."year"
        AND d_sub."last_round" = d."last_round"
    )
  AND d."first_round" <> d."last_round"
ORDER BY d."driver_id", d."year";