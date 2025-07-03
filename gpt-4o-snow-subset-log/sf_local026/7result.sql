WITH TotalRunsPerOver AS (
    SELECT 
        b."match_id",
        b."over_id",
        b."bowler",
        SUM(s."runs_scored") AS "total_runs_in_over"
    FROM IPL.IPL.BALL_BY_BALL AS b
    JOIN IPL.IPL.BATSMAN_SCORED AS s
    ON b."match_id" = s."match_id" AND b."over_id" = s."over_id" AND b."ball_id" = s."ball_id" AND b."innings_no" = s."innings_no"
    GROUP BY b."match_id", b."over_id", b."bowler"
),
MaxRunsPerMatch AS (
    SELECT 
        "match_id",
        "over_id",
        MAX("total_runs_in_over") AS "max_runs_in_match"
    FROM TotalRunsPerOver
    GROUP BY "match_id", "over_id"
),
OversWithMaxRuns AS (
    SELECT
        t."match_id",
        t."over_id",
        t."bowler",
        t."total_runs_in_over"
    FROM TotalRunsPerOver AS t
    JOIN MaxRunsPerMatch AS m
    ON t."match_id" = m."match_id" AND t."over_id" = m."over_id" AND t."total_runs_in_over" = m."max_runs_in_match"
),
Top3Bowlers AS (
    SELECT
        f."bowler",
        f."match_id",
        f."over_id",
        f."total_runs_in_over",
        RANK() OVER (ORDER BY f."total_runs_in_over" DESC) AS "rank"
    FROM OversWithMaxRuns AS f
)
SELECT 
    p."player_name" AS "bowler_name",
    t."match_id",
    t."over_id",
    t."total_runs_in_over" AS "max_runs_conceded"
FROM Top3Bowlers AS t
JOIN IPL.IPL.PLAYER AS p
ON t."bowler" = p."player_id"
WHERE t."rank" <= 3
ORDER BY t."total_runs_in_over" DESC NULLS LAST;