WITH
-- Identify overtakes related to retirements (R)
retirement_overtakes AS (
    SELECT DISTINCT 
        lp."race_id",
        lp."driver_id",
        lp."lap",
        'R' AS "overtake_type"
    FROM F1.F1.LAP_POSITIONS lp
    LEFT JOIN F1.F1.RETIREMENTS r
        ON lp."race_id" = r."race_id" 
        AND lp."driver_id" = r."driver_id" 
        AND lp."lap" = r."lap"
    WHERE lp."lap" <= 5
      AND r."retirement_type" IS NOT NULL
),
-- Identify overtakes related to pit stops (P)
pit_overtakes AS (
    SELECT DISTINCT 
        lp."race_id",
        lp."driver_id",
        lp."lap",
        'P' AS "overtake_type"
    FROM F1.F1.LAP_POSITIONS lp
    JOIN F1.F1.PIT_STOPS ps
        ON lp."race_id" = ps."race_id" 
        AND lp."driver_id" = ps."driver_id" 
        AND lp."lap" = ps."lap"
    WHERE lp."lap" <= 5
),
-- Identify start-related overtakes (S)
start_overtakes AS (
    SELECT DISTINCT 
        lp."race_id",
        lp."driver_id",
        lp."lap",
        'S' AS "overtake_type"
    FROM F1.F1.LAP_POSITIONS lp
    JOIN F1.F1.QUALIFYING q
        ON lp."race_id" = q."race_id" 
        AND lp."driver_id" = q."driver_id"
    WHERE lp."lap" = 1
      AND ABS(lp."position" - q."position") <= 2
),
-- Identify standard on-track overtakes (T)
track_overtakes AS (
    SELECT DISTINCT 
        lp1."race_id",
        lp1."driver_id",
        lp1."lap",
        'T' AS "overtake_type"
    FROM F1.F1.LAP_POSITIONS lp1
    LEFT JOIN F1.F1.LAP_POSITIONS lp2
        ON lp1."race_id" = lp2."race_id" 
        AND lp1."driver_id" = lp2."driver_id" 
        AND lp1."lap" = lp2."lap" + 1
    WHERE lp1."lap" <= 5
      AND lp2."position" > lp1."position"
),
-- Combine all overtakes into a single set
all_overtakes AS (
    SELECT * FROM retirement_overtakes
    UNION ALL
    SELECT * FROM pit_overtakes
    UNION ALL
    SELECT * FROM start_overtakes
    UNION ALL
    SELECT * FROM track_overtakes
)
-- Count overtakes by category
SELECT 
    "overtake_type", 
    COUNT(*) AS "overtake_count"
FROM all_overtakes
GROUP BY "overtake_type"
ORDER BY "overtake_type";