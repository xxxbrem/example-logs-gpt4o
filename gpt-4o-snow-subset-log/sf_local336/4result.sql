WITH RetirementOvertakes AS (
    SELECT 
        r."race_id", 
        COUNT(*) AS "retirement_overtake_count"
    FROM 
        F1.F1.RETIREMENTS r 
    JOIN 
        F1.F1.LAP_POSITIONS lp
    ON 
        r."race_id" = lp."race_id" 
        AND r."driver_id" = lp."driver_id"
    WHERE 
        lp."lap" <= 5
    GROUP BY 
        r."race_id"
),
PitStopOvertakes AS (
    SELECT 
        ps."race_id", 
        COUNT(*) AS "pit_overtake_count"
    FROM 
        F1.F1.PIT_STOPS ps
    JOIN 
        F1.F1.LAP_POSITIONS lp
    ON 
        ps."race_id" = lp."race_id" 
        AND ps."lap" = lp."lap"
    WHERE 
        ps."lap" <= 5
    GROUP BY 
        ps."race_id"
),
StartOvertakes AS (
    SELECT 
        lp1."race_id", 
        COUNT(*) AS "start_overtake_count"
    FROM 
        F1.F1.LAP_POSITIONS lp1
    JOIN 
        F1.F1.LAP_POSITIONS lp2
    ON 
        lp1."race_id" = lp2."race_id"
        AND lp1."lap" = 1
        AND lp2."lap" = 0
        AND ABS(lp1."position" - lp2."position") <= 2
        AND lp1."driver_id" != lp2."driver_id"
    WHERE 
        lp1."lap" <= 5
    GROUP BY 
        lp1."race_id"
),
TrackOvertakes AS (
    SELECT 
        lp1."race_id", 
        COUNT(*) AS "track_overtake_count"
    FROM 
        F1.F1.LAP_POSITIONS lp1
    JOIN 
        F1.F1.LAP_POSITIONS lp2
    ON 
        lp1."race_id" = lp2."race_id"
        AND lp1."lap" = lp2."lap" + 1
        AND lp1."position" < lp2."position"
        AND lp1."driver_id" != lp2."driver_id"
    WHERE 
        lp1."lap" <= 5
    GROUP BY 
        lp1."race_id"
)
SELECT 
    COALESCE(ro."race_id", po."race_id", so."race_id", tr."race_id") AS "race_id",
    COALESCE(ro."retirement_overtake_count", 0) AS "retirement_overtake_count",
    COALESCE(po."pit_overtake_count", 0) AS "pit_overtake_count",
    COALESCE(so."start_overtake_count", 0) AS "start_overtake_count",
    COALESCE(tr."track_overtake_count", 0) AS "track_overtake_count"
FROM 
    RetirementOvertakes ro
FULL OUTER JOIN 
    PitStopOvertakes po ON ro."race_id" = po."race_id"
FULL OUTER JOIN 
    StartOvertakes so ON COALESCE(ro."race_id", po."race_id") = so."race_id"
FULL OUTER JOIN 
    TrackOvertakes tr ON COALESCE(ro."race_id", po."race_id", so."race_id") = tr."race_id"
ORDER BY 
    COALESCE(ro."race_id", po."race_id", so."race_id", tr."race_id");