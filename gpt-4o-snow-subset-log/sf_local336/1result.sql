WITH Retirements AS (
    -- Categorize overtakes due to retirements in the first 5 laps
    SELECT 
        lp."race_id",
        lp."lap",
        lp."driver_id",
        'R' AS overtake_type
    FROM F1.F1.LAP_POSITIONS lp
    JOIN F1.F1.RETIREMENTS r
    ON lp."race_id" = r."race_id" AND lp."lap" = r."lap" AND lp."driver_id" = r."driver_id"
    WHERE lp."lap" <= 5
),
PitStops AS (
    -- Categorize overtakes due to pit stops in the first 5 laps
    SELECT 
        lp."race_id",
        lp."lap",
        lp."driver_id",
        'P' AS overtake_type
    FROM F1.F1.LAP_POSITIONS lp
    JOIN F1.F1.PIT_STOPS ps
    ON lp."race_id" = ps."race_id" AND lp."lap" = ps."lap" AND lp."driver_id" = ps."driver_id"
    WHERE lp."lap" <= 5
),
StartRelated AS (
    -- Categorize overtakes during race start in the first lap
    SELECT 
        lp."race_id",
        lp."lap",
        lp."driver_id",
        'S' AS overtake_type
    FROM F1.F1.LAP_POSITIONS lp
    JOIN F1.F1.RESULTS res
    ON lp."race_id" = res."race_id" AND lp."driver_id" = res."driver_id"
    WHERE lp."lap" = 1 AND ABS(lp."position" - res."grid") <= 2
),
TrackOvertakes AS (
    -- Categorize standard track overtakes (default category if none of the above applies)
    SELECT 
        lp."race_id",
        lp."lap",
        lp."driver_id",
        'T' AS overtake_type
    FROM F1.F1.LAP_POSITIONS lp
    LEFT JOIN F1.F1.RETIREMENTS r
    ON lp."race_id" = r."race_id" AND lp."lap" = r."lap" AND lp."driver_id" = r."driver_id"
    LEFT JOIN F1.F1.PIT_STOPS ps
    ON lp."race_id" = ps."race_id" AND lp."lap" = ps."lap" AND lp."driver_id" = ps."driver_id"
    LEFT JOIN F1.F1.RESULTS res
    ON lp."race_id" = res."race_id" AND lp."driver_id" = res."driver_id" AND lp."lap" = 1 AND ABS(lp."position" - res."grid") <= 2
    WHERE lp."lap" <= 5 
    AND r."driver_id" IS NULL 
    AND ps."driver_id" IS NULL 
    AND res."driver_id" IS NULL
)
-- Aggregate the counts of overtakes by type
SELECT 
    overtake_type, 
    COUNT(*) AS overtake_count 
FROM (
    SELECT * FROM Retirements
    UNION ALL 
    SELECT * FROM PitStops
    UNION ALL 
    SELECT * FROM StartRelated
    UNION ALL 
    SELECT * FROM TrackOvertakes
) OvertakeData
GROUP BY overtake_type;