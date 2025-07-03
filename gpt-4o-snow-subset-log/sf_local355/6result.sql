WITH eligible_drivers AS (
    SELECT DISTINCT d1."driver_id", d1."year", d1."first_round", d1."last_round"
    FROM F1.F1.DRIVES d1
    JOIN F1.F1.DRIVES d2
      ON d1."driver_id" = d2."driver_id"
     AND d1."year" = d2."year"
    WHERE d1."last_round" + 1 = d2."first_round"
      AND d1."constructor_id" != d2."constructor_id"
      AND (d1."last_round" - d1."first_round" + 1) < 3
)
SELECT 
    AVG("first_round" * 1.0) AS "average_first_round",
    AVG("last_round" * 1.0) AS "average_last_round"
FROM eligible_drivers;