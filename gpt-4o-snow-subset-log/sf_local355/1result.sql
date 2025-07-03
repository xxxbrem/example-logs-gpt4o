WITH MissingRaces AS (
    SELECT 
        d1."driver_id",
        d1."year",
        d1."constructor_id" AS "constructor_before",
        d2."constructor_id" AS "constructor_after",
        d1."last_round",
        d2."first_round",
        d2."first_round" - d1."last_round" AS "missed_races"
    FROM F1.F1.DRIVES d1
    JOIN F1.F1.DRIVES d2 
      ON d1."driver_id" = d2."driver_id"
      AND d1."year" = d2."year"
      AND d1."last_round" < d2."first_round"
    WHERE d2."first_round" - d1."last_round" < 3
      AND d1."constructor_id" != d2."constructor_id"
),
OverallAverages AS (
    SELECT 
        AVG("first_round") AS "avg_first_round",
        AVG("last_round") AS "avg_last_round"
    FROM (
        SELECT 
            "first_round",
            "last_round"
        FROM MissingRaces
    ) sub
)
SELECT 
    "avg_first_round",
    "avg_last_round"
FROM OverallAverages;