WITH Retirements AS (
    -- Overtakes during retirements (R)
    SELECT DISTINCT 
        "race_id", 
        "driver_id", 
        'R' AS "overtake_type"
    FROM F1.F1.RETIREMENTS
    WHERE "lap" <= 5
),
PitStopOvertakes AS (
    -- Overtakes due to pit stops (P)
    SELECT DISTINCT 
        ps."race_id", 
        ps."driver_id", 
        'P' AS "overtake_type"
    FROM F1.F1.PIT_STOPS ps
    WHERE ps."lap" <= 5
),
StartOvertakes AS (
    -- Overtakes at the start of the race (S)
    SELECT DISTINCT 
        q."race_id", 
        lp."driver_id",
        'S' AS "overtake_type"
    FROM F1.F1.QUALIFYING q
    JOIN F1.F1.LAP_POSITIONS lp
        ON q."race_id" = lp."race_id" AND q."driver_id" = lp."driver_id"
    WHERE lp."lap" = 1 AND ABS(q."position" - lp."position") > 2
),
TrackOvertakes AS (
    -- Overtakes under normal racing conditions (T)
    SELECT 
        "race_id", 
        "driver_id", 
        'T' AS "overtake_type"
    FROM F1.F1.LAP_TIMES
    WHERE "lap" <= 5
)
SELECT 
    "overtake_type",
    COUNT(*) AS "overtake_count"
FROM (
    SELECT * FROM Retirements
    UNION ALL
    SELECT * FROM PitStopOvertakes
    UNION ALL
    SELECT * FROM StartOvertakes
    UNION ALL
    SELECT * FROM TrackOvertakes
) AS AllOvertakes
GROUP BY "overtake_type"
ORDER BY "overtake_type";