WITH 
-- Identify retirements within the first 5 laps
retirement_overtakes AS (
    SELECT 
        t1."race_id", 
        t1."driver_id" AS "overtaking_driver", 
        COUNT(*) AS "retirement_overtake_count"
    FROM F1.F1.LAP_POSITIONS t1
    JOIN F1.F1.RETIREMENTS t2
        ON t1."race_id" = t2."race_id" AND t1."lap" = t2."lap"
    WHERE t1."lap" <= 5
    GROUP BY t1."race_id", t1."driver_id"
),

-- Identify pit stop-related overtakes within the first 5 laps
pit_stop_overtakes AS (
    SELECT 
        t1."race_id", 
        t1."driver_id", 
        COUNT(*) AS "pit_stop_overtake_count"
    FROM F1.F1.LAP_TIMES t1
    JOIN F1.F1.PIT_STOPS t2
        ON t1."race_id" = t2."race_id" 
        AND t1."driver_id" = t2."driver_id" 
        AND (t1."lap" = t2."lap" - 1 OR t1."lap" = t2."lap")
    WHERE t1."lap" <= 5
    GROUP BY t1."race_id", t1."driver_id"
),

-- Identify start-related overtakes on lap 1
start_overtakes AS (
    SELECT 
        t1."race_id", 
        t1."driver_id", 
        COUNT(*) AS "start_overtake_count"
    FROM F1.F1.LAP_TIMES t1
    JOIN F1.F1.QUALIFYING t2
        ON t1."race_id" = t2."race_id" 
        AND t1."driver_id" = t2."driver_id"
    WHERE t1."lap" = 1 
        AND ABS(t1."position" - t2."position") <= 2
    GROUP BY t1."race_id", t1."driver_id"
),

-- Standard on-track overtakes within the first 5 laps
track_overtakes AS (
    SELECT 
        t1."race_id", 
        t1."driver_id", 
        COUNT(*) AS "track_overtake_count"
    FROM F1.F1.LAP_TIMES_EXT t1
    JOIN F1.F1.LAP_TIMES_EXT t2
        ON t1."race_id" = t2."race_id" 
        AND t1."driver_id" = t2."driver_id" 
        AND t1."lap" = t2."lap" + 1
    WHERE t1."lap" <= 5 
        AND t1."position" < t2."position"
    GROUP BY t1."race_id", t1."driver_id"
)

-- Combine results and aggregate each type of overtake
SELECT 
    COALESCE(retirement_overtakes."race_id", pit_stop_overtakes."race_id", start_overtakes."race_id", track_overtakes."race_id") AS "race_id",
    COALESCE(SUM(retirement_overtakes."retirement_overtake_count"), 0) AS "retirement_overtakes",
    COALESCE(SUM(pit_stop_overtakes."pit_stop_overtake_count"), 0) AS "pit_stop_overtakes",
    COALESCE(SUM(start_overtakes."start_overtake_count"), 0) AS "start_overtakes",
    COALESCE(SUM(track_overtakes."track_overtake_count"), 0) AS "track_overtakes"
FROM retirement_overtakes
FULL OUTER JOIN pit_stop_overtakes 
    ON retirement_overtakes."race_id" = pit_stop_overtakes."race_id"
FULL OUTER JOIN start_overtakes 
    ON COALESCE(retirement_overtakes."race_id", pit_stop_overtakes."race_id") = start_overtakes."race_id"
FULL OUTER JOIN track_overtakes 
    ON COALESCE(retirement_overtakes."race_id", pit_stop_overtakes."race_id", start_overtakes."race_id") = track_overtakes."race_id"
GROUP BY COALESCE(retirement_overtakes."race_id", pit_stop_overtakes."race_id", start_overtakes."race_id", track_overtakes."race_id")
ORDER BY "race_id";