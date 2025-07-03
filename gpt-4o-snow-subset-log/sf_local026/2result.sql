WITH Overwise_Runs AS (
    SELECT 
        b."match_id",
        b."over_id",
        b."bowler",
        SUM(bs."runs_scored" + COALESCE(er."extra_runs", 0)) AS "total_runs_conceded"
    FROM "IPL"."IPL"."BALL_BY_BALL" b
    LEFT JOIN "IPL"."IPL"."BATSMAN_SCORED" bs 
        ON b."match_id" = bs."match_id" 
        AND b."over_id" = bs."over_id" 
        AND b."ball_id" = bs."ball_id" 
        AND b."innings_no" = bs."innings_no"
    LEFT JOIN "IPL"."IPL"."EXTRA_RUNS" er 
        ON b."match_id" = er."match_id" 
        AND b."over_id" = er."over_id" 
        AND b."ball_id" = er."ball_id" 
        AND b."innings_no" = er."innings_no"
    GROUP BY b."match_id", b."over_id", b."bowler"
),
MaxOvers AS (
    SELECT DISTINCT
        r."match_id",
        r."over_id",
        r."bowler",
        r."total_runs_conceded"
    FROM Overwise_Runs r
    JOIN (
        SELECT 
            "match_id",
            MAX("total_runs_conceded") AS "max_runs_in_match"
        FROM Overwise_Runs
        GROUP BY "match_id"
    ) m ON r."match_id" = m."match_id" AND r."total_runs_conceded" = m."max_runs_in_match"
)
SELECT 
    mo."match_id",
    mo."bowler",
    p."player_name",
    p."country_name",
    mo."total_runs_conceded"
FROM MaxOvers mo
JOIN "IPL"."IPL"."PLAYER" p 
    ON mo."bowler" = p."player_id"
ORDER BY mo."total_runs_conceded" DESC NULLS LAST
LIMIT 3;