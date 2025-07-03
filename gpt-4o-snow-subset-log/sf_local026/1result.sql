WITH Total_Runs_Over AS (
    SELECT 
        b."match_id", 
        b."innings_no", 
        b."over_id", 
        SUM(b."runs_scored") + COALESCE(SUM(e."extra_runs"), 0) AS "total_runs"
    FROM 
        IPL.IPL.BATSMAN_SCORED b
    LEFT JOIN 
        IPL.IPL.EXTRA_RUNS e
    ON 
        b."match_id" = e."match_id" AND 
        b."innings_no" = e."innings_no" AND 
        b."over_id" = e."over_id" AND 
        b."ball_id" = e."ball_id"
    GROUP BY 
        b."match_id", b."innings_no", b."over_id"
),
Max_Over_Runs AS (
    SELECT 
        t."match_id", 
        t."innings_no", 
        t."over_id", 
        t."total_runs"
    FROM 
        Total_Runs_Over t
    WHERE 
        t."total_runs" = (
            SELECT MAX(t_sub."total_runs") 
            FROM Total_Runs_Over t_sub 
            WHERE t_sub."match_id" = t."match_id"
        )
),
Bowler_Total_Runs AS (
    SELECT 
        b."bowler", 
        p."player_name" AS "bowler_name", 
        m."match_id", 
        m."innings_no", 
        m."over_id", 
        m."total_runs"
    FROM 
        Max_Over_Runs m
    JOIN 
        IPL.IPL.BALL_BY_BALL b
    ON 
        m."match_id" = b."match_id" AND 
        m."innings_no" = b."innings_no" AND 
        m."over_id" = b."over_id"
    JOIN 
        IPL.IPL.PLAYER p
    ON 
        b."bowler" = p."player_id"
    GROUP BY 
        b."bowler", 
        p."player_name", 
        m."match_id", 
        m."innings_no", 
        m."over_id", 
        m."total_runs"
)
SELECT 
    "bowler_name", 
    "match_id", 
    "innings_no", 
    "over_id", 
    "total_runs"
FROM 
    Bowler_Total_Runs
ORDER BY 
    "total_runs" DESC NULLS LAST
LIMIT 3;