SELECT DISTINCT 
    dr."driver_id", 
    d."full_name", 
    dr."year", 
    c."name" AS "constructor_name"
FROM F1.F1.DRIVES dr
JOIN F1.F1.DRIVERS d
    ON dr."driver_id" = d."driver_id"
JOIN F1.F1.CONSTRUCTORS c
    ON dr."constructor_id" = c."constructor_id"
WHERE dr."year" BETWEEN 1950 AND 1959
  AND dr."is_first_drive_of_season" = 1
  AND dr."is_final_drive_of_season" = 1
  AND dr."first_round" != dr."last_round"
  AND dr."driver_id" IN (
      SELECT "driver_id"
      FROM F1.F1.DRIVES
      WHERE "year" BETWEEN 1950 AND 1959
      GROUP BY "driver_id", "year"
      HAVING COUNT(DISTINCT "first_round") >= 2
  )
LIMIT 20;