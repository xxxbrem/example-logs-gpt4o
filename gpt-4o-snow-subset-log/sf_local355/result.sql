SELECT 
    AVG(d2."first_round" - 1) AS "avg_first_round_missed", 
    AVG(d1."last_round" + 1) AS "avg_last_round_missed"
FROM F1.F1.DRIVES d1
JOIN F1.F1.DRIVES d2 
    ON d1."driver_id" = d2."driver_id" 
    AND d1."year" = d2."year"
WHERE d2."first_round" - d1."last_round" - 1 < 3
  AND d1."constructor_id" <> d2."constructor_id";