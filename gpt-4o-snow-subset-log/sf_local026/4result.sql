WITH MaxRunsPerMatch AS (
    -- Calculate max runs conceded in a single over for each match
    SELECT 
        b."match_id", 
        b."over_id", 
        b."bowler", 
        SUM(bat."runs_scored") AS "batsman_runs",
        SUM(COALESCE(extra."extra_runs", 0)) AS "extra_runs",
        SUM(bat."runs_scored") + SUM(COALESCE(extra."extra_runs", 0)) AS "total_over_runs"
    FROM IPL.IPL.BALL_BY_BALL b
    LEFT JOIN IPL.IPL.BATSMAN_SCORED bat 
        ON b."match_id" = bat."match_id" 
        AND b."over_id" = bat."over_id"
        AND b."ball_id" = bat."ball_id"
        AND b."innings_no" = bat."innings_no"
    LEFT JOIN IPL.IPL.EXTRA_RUNS extra 
        ON b."match_id" = extra."match_id" 
        AND b."over_id" = extra."over_id"
        AND b."ball_id" = extra."ball_id" 
        AND b."innings_no" = extra."innings_no"
    GROUP BY b."match_id", b."over_id", b."bowler"
),
MaxOversInMatch AS (
    -- Find the overs with the maximum runs conceded for each match
    SELECT 
        "match_id", 
        MAX("total_over_runs") AS "max_runs_in_over"
    FROM MaxRunsPerMatch
    GROUP BY "match_id"
),
TopOvers AS (
    -- Get the details of bowlers and overs where maximum runs were conceded in their respective matches
    SELECT DISTINCT
        mrm."bowler",
        mrm."match_id",
        mrm."over_id",
        mom."max_runs_in_over" AS "runs_conceded"
    FROM MaxRunsPerMatch mrm
    JOIN MaxOversInMatch mom
        ON mrm."match_id" = mom."match_id" 
        AND mrm."total_over_runs" = mom."max_runs_in_over"
),
TopThreeBowlers AS (
    -- Find the top 3 bowlers who conceded the highest runs in a single over
    SELECT 
        "bowler", 
        "match_id", 
        "over_id", 
        "runs_conceded"
    FROM TopOvers
    ORDER BY "runs_conceded" DESC NULLS LAST
    LIMIT 3
)
-- Add player details to the top 3 bowlers
SELECT 
    ttb."bowler", 
    p."player_name", 
    ttb."match_id", 
    ttb."over_id", 
    ttb."runs_conceded"
FROM TopThreeBowlers ttb
JOIN IPL.IPL.PLAYER p
    ON ttb."bowler" = p."player_id"
ORDER BY ttb."runs_conceded" DESC NULLS LAST;