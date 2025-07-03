WITH 
-- Identify overtakes during retirements in the first five laps
RetirementOvertakes AS (
    SELECT r."race_id", r."driver_id", r."lap" AS "retire_lap"
    FROM F1.F1.RETIREMENTS r
    WHERE r."lap" <= 5
),
-- Identify pit stop-related overtakes in the first five laps
PitStopOvertakes AS (
    SELECT ps."race_id", ps."driver_id", ps."lap" AS "pit_lap"
    FROM F1.F1.PIT_STOPS ps
    WHERE ps."lap" <= 5
),
-- Identify start-related overtakes in the first lap
StartOvertakes AS (
    SELECT q."race_id", q."driver_id", q."position" AS "grid_position", lte."position" AS "lap_1_position"
    FROM F1.F1.QUALIFYING q
    JOIN F1.F1.LAP_TIMES_EXT lte ON q."race_id" = lte."race_id" AND q."driver_id" = lte."driver_id"
    WHERE lte."lap" = 1 AND ABS(q."position" - lte."position") <= 2
),
-- Identify standard on-track overtakes by comparing consecutive lap positions
TrackOvertakes AS (
    SELECT lp1."race_id", lp1."driver_id", lp1."lap", lp2."position" AS "previous_position", lp1."position" AS "current_position"
    FROM F1.F1.LAP_POSITIONS lp1
    JOIN F1.F1.LAP_POSITIONS lp2 
      ON lp1."race_id" = lp2."race_id" 
      AND lp1."driver_id" = lp2."driver_id" 
      AND lp1."lap" = lp2."lap" + 1
    WHERE lp1."lap" <= 5 AND lp1."position" < lp2."position"
)
-- Consolidate results to count overtakes in each category
SELECT 
    'Retirement' AS "Overtake_Type", 
    COUNT(*) AS "Overtake_Count"
FROM RetirementOvertakes
UNION ALL
SELECT 
    'Pit Stop' AS "Overtake_Type", 
    COUNT(*) AS "Overtake_Count"
FROM PitStopOvertakes
UNION ALL
SELECT 
    'Start' AS "Overtake_Type", 
    COUNT(*) AS "Overtake_Count"
FROM StartOvertakes
UNION ALL
SELECT 
    'Track' AS "Overtake_Type", 
    COUNT(*) AS "Overtake_Count"
FROM TrackOvertakes;