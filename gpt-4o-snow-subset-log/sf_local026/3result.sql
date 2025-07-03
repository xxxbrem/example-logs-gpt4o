WITH max_runs_per_over AS (
    -- Step 1: Compute total runs conceded for each ball, combine runs_scored and extra_runs.
    SELECT 
        b."match_id",
        b."over_id",
        b."bowler",
        COALESCE(bs."runs_scored", 0) + COALESCE(er."extra_runs", 0) AS "total_runs"
    FROM IPL.IPL.BALL_BY_BALL b
    LEFT JOIN IPL.IPL.BATSMAN_SCORED bs 
        ON b."match_id" = bs."match_id" 
        AND b."over_id" = bs."over_id" 
        AND b."ball_id" = bs."ball_id" 
        AND b."innings_no" = bs."innings_no"
    LEFT JOIN IPL.IPL.EXTRA_RUNS er 
        ON b."match_id" = er."match_id" 
        AND b."over_id" = er."over_id" 
        AND b."ball_id" = er."ball_id" 
        AND b."innings_no" = er."innings_no"
),
overwise_runs AS (
    -- Step 2: Aggregate total runs conceded for each bowler per over.
    SELECT 
        "match_id",
        "over_id",
        "bowler",
        SUM("total_runs") AS "runs_in_over"
    FROM max_runs_per_over
    GROUP BY "match_id", "over_id", "bowler"
),
max_runs_per_match AS (
    -- Step 3: Find the overs where the maximum runs were conceded in each match.
    SELECT 
        "match_id",
        "over_id",
        "bowler",
        "runs_in_over",
        RANK() OVER (PARTITION BY "match_id" ORDER BY "runs_in_over" DESC) AS "rank_within_match"
    FROM overwise_runs
),
max_runs_overs_all_matches AS (
    -- Step 4: Filter overs with maximum runs per match.
    SELECT 
        "match_id",
        "over_id",
        "bowler",
        "runs_in_over"
    FROM max_runs_per_match
    WHERE "rank_within_match" = 1
),
top_3_bowlers AS (
    -- Step 5: Rank all maximum overs across matches by runs conceded.
    SELECT 
        "match_id",
        "over_id",
        "bowler",
        "runs_in_over",
        RANK() OVER (ORDER BY "runs_in_over" DESC) AS "overall_rank"
    FROM max_runs_overs_all_matches
)
-- Step 6: Fetch details of the top 3 bowlers who conceded the most runs in a single over.
SELECT 
    top_3_bowlers."match_id",
    top_3_bowlers."over_id",
    p."player_name" AS "bowler_name",
    top_3_bowlers."runs_in_over"
FROM top_3_bowlers
JOIN IPL.IPL.PLAYER p 
    ON top_3_bowlers."bowler" = p."player_id"
WHERE top_3_bowlers."overall_rank" <= 3
ORDER BY top_3_bowlers."runs_in_over" DESC NULLS LAST
LIMIT 3;