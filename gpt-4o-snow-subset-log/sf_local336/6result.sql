WITH retirements_overtakes AS (
    SELECT 
        "race_id",
        COUNT(*) AS "retirement_overtakes_count"
    FROM F1.F1.RETIREMENTS
    WHERE "lap" <= 5
    GROUP BY "race_id"
),
pit_stop_overtakes AS (
    SELECT 
        p."race_id",
        COUNT(*) AS "pit_stop_overtakes_count"
    FROM F1.F1.PIT_STOPS p
    JOIN F1.F1.LAP_POSITIONS l
    ON p."driver_id" = l."driver_id" AND p."race_id" = l."race_id"
    WHERE p."lap" <= 5
    GROUP BY p."race_id"
),
start_overtakes AS (
    SELECT 
        lt1."race_id",
        COUNT(*) AS "start_overtakes_count"
    FROM F1.F1.LAP_TIMES lt1
    JOIN F1.F1.LAP_TIMES lt2 
    ON lt1."driver_id" != lt2."driver_id" AND lt1."race_id" = lt2."race_id"
    WHERE lt1."lap" = 1 AND lt2."lap" = 1 
    AND ABS(lt1."position" - lt2."position") <= 2
    AND lt1."position" > lt2."position"
    GROUP BY lt1."race_id"
),
track_overtakes AS (
    SELECT 
        lt1."race_id",
        COUNT(*) AS "track_overtakes_count"
    FROM F1.F1.LAP_TIMES lt1
    JOIN F1.F1.LAP_TIMES lt2 
    ON lt1."driver_id" = lt2."driver_id" AND lt1."race_id" = lt2."race_id"
    WHERE lt1."lap" <= 5 AND lt2."lap" <= 5 AND lt1."position" > lt2."position"
    GROUP BY lt1."race_id"
)
SELECT 
    COALESCE(ro."race_id", po."race_id", so."race_id", tr."race_id") AS "race_id",
    COALESCE(ro."retirement_overtakes_count", 0) AS "retirement_overtakes",
    COALESCE(po."pit_stop_overtakes_count", 0) AS "pit_stop_overtakes",
    COALESCE(so."start_overtakes_count", 0) AS "start_overtakes",
    COALESCE(tr."track_overtakes_count", 0) AS "track_overtakes"
FROM retirements_overtakes ro
FULL OUTER JOIN pit_stop_overtakes po ON ro."race_id" = po."race_id"
FULL OUTER JOIN start_overtakes so ON COALESCE(ro."race_id", po."race_id") = so."race_id"
FULL OUTER JOIN track_overtakes tr ON COALESCE(ro."race_id", po."race_id", so."race_id") = tr."race_id"
ORDER BY "race_id";