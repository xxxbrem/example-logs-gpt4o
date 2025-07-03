WITH Retirements AS (
    SELECT 
        COUNT(*) AS "count", 
        'Retirement' AS "overtake_type"
    FROM 
        F1.F1.RETIREMENTS
    WHERE 
        "lap" <= 5
),
PitStops AS (
    SELECT 
        COUNT(*) AS "count", 
        'Pit' AS "overtake_type"
    FROM 
        F1.F1.PIT_STOPS PS1
    WHERE 
        PS1."lap" <= 5
        AND EXISTS (
            SELECT 1 
            FROM F1.F1.LAP_POSITIONS LP 
            WHERE LP."race_id" = PS1."race_id" 
            AND LP."lap" = PS1."lap"
        )
),
StartOvertakes AS (
    SELECT 
        COUNT(*) AS "count", 
        'Start' AS "overtake_type"
    FROM (
        SELECT 
            LP1."race_id", 
            LP1."driver_id", 
            LP1."lap", 
            LP1."position" AS "current_position", 
            LP2."position" AS "previous_position"
        FROM 
            F1.F1.LAP_POSITIONS LP1
        JOIN 
            F1.F1.LAP_POSITIONS LP2 
        ON 
            LP1."driver_id" = LP2."driver_id" 
            AND LP1."race_id" = LP2."race_id"
            AND LP1."lap" = 1
            AND LP2."lap" = 0  -- Comparing starting grid positions
        WHERE 
            ABS(LP1."position" - LP2."position") <= 2 -- Within 2 grid positions
    ) AS StartConditions
),
TrackOvertakes AS (
    SELECT 
        COUNT(*) AS "count", 
        'Track' AS "overtake_type"
    FROM (
        SELECT 
            LP1."race_id", 
            LP1."driver_id", 
            LP1."lap", 
            LP1."position" AS "current_position", 
            LP2."position" AS "next_position"
        FROM 
            F1.F1.LAP_POSITIONS LP1
        JOIN 
            F1.F1.LAP_POSITIONS LP2 
        ON 
            LP1."driver_id" = LP2."driver_id" 
            AND LP1."race_id" = LP2."race_id"
            AND LP1."lap" + 1 = LP2."lap"  -- Comparing consecutive laps
        WHERE 
            LP1."position" > LP2."position"
    ) AS TrackConditions
)
-- Combine all categories and return the count of overtakes in each category.
SELECT 
    "overtake_type", 
    "count"
FROM (
    SELECT * FROM Retirements
    UNION ALL
    SELECT * FROM PitStops
    UNION ALL
    SELECT * FROM StartOvertakes
    UNION ALL
    SELECT * FROM TrackOvertakes
)
LIMIT 20;