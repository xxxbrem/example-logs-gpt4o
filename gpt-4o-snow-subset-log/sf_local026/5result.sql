WITH max_runs_overs AS (
    SELECT 
        bs."match_id", 
        bs."innings_no", 
        bs."over_id", 
        SUM(bs."runs_scored" + COALESCE(er."extra_runs", 0)) AS "total_runs"
    FROM 
        IPL.IPL.BATSMAN_SCORED bs
    LEFT JOIN 
        IPL.IPL.EXTRA_RUNS er
    ON 
        bs."match_id" = er."match_id" 
        AND bs."ball_id" = er."ball_id" 
        AND bs."innings_no" = er."innings_no"
    GROUP BY 
        bs."match_id", bs."innings_no", bs."over_id"
    QUALIFY ROW_NUMBER() OVER (PARTITION BY bs."match_id", bs."innings_no" ORDER BY SUM(bs."runs_scored" + COALESCE(er."extra_runs", 0)) DESC) = 1
),
bowler_runs_in_max_overs AS (
    SELECT 
        o."match_id", 
        o."innings_no", 
        o."over_id", 
        bb."bowler", 
        SUM(bs."runs_scored" + COALESCE(er."extra_runs", 0)) AS "runs_by_bowler"
    FROM 
        max_runs_overs o
    JOIN 
        IPL.IPL.BALL_BY_BALL bb
    ON 
        o."match_id" = bb."match_id" 
        AND o."innings_no" = bb."innings_no" 
        AND o."over_id" = bb."over_id"
    LEFT JOIN 
        IPL.IPL.BATSMAN_SCORED bs
    ON 
        bb."match_id" = bs."match_id" 
        AND bb."innings_no" = bs."innings_no" 
        AND bb."over_id" = bs."over_id" 
        AND bb."ball_id" = bs."ball_id"
    LEFT JOIN 
        IPL.IPL.EXTRA_RUNS er
    ON 
        bb."match_id" = er."match_id" 
        AND bb."innings_no" = er."innings_no" 
        AND bb."over_id" = er."over_id" 
        AND bb."ball_id" = er."ball_id"
    GROUP BY 
        o."match_id", o."innings_no", o."over_id", bb."bowler"
),
top_3_bowlers AS (
    SELECT 
        "bowler", 
        "match_id", 
        "runs_by_bowler"
    FROM 
        bowler_runs_in_max_overs
    ORDER BY 
        "runs_by_bowler" DESC NULLS LAST
    LIMIT 3
)
SELECT 
    t3."bowler", 
    t3."match_id", 
    t3."runs_by_bowler"
FROM 
    top_3_bowlers t3
ORDER BY 
    t3."runs_by_bowler" DESC NULLS LAST;