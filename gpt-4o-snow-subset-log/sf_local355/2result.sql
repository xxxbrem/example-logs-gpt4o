WITH Missed_Races AS (
    -- Identify drivers who missed races by finding gaps in their first_round and last_round
    SELECT
        d1."driver_id",
        d1."year",
        d1."constructor_id" AS "prev_constructor_id",
        d1."last_round" AS "prev_last_round",
        d2."constructor_id" AS "next_constructor_id",
        d2."first_round" AS "next_first_round",
        d1."last_round" + 1 AS "first_missed_round",
        d2."first_round" - 1 AS "last_missed_round",
        d2."first_round" - d1."last_round" - 1 AS "missed_races_count"
    FROM F1.F1.DRIVES d1
    JOIN F1.F1.DRIVES d2
      ON d1."driver_id" = d2."driver_id"
     AND d1."year" = d2."year"
     AND d1."last_round" + 1 < d2."first_round" -- Ensure a gap exists
    WHERE d1."constructor_id" != d2."constructor_id" -- Constructor switch
),
Filtered_Missed_Races AS (
    -- Filter to include only drivers who missed fewer than three races
    SELECT *
    FROM Missed_Races
    WHERE "missed_races_count" < 3
),
Average_Missed_Rounds AS (
    -- Calculate the overall averages for the first and last missed rounds
    SELECT
        AVG("first_missed_round") AS "avg_first_missed_round",
        AVG("last_missed_round") AS "avg_last_missed_round"
    FROM Filtered_Missed_Races
)
SELECT * 
FROM Average_Missed_Rounds;