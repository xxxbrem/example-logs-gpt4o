WITH player_scores AS (
    SELECT 
        bbb."match_id", 
        bbb."striker", 
        SUM(bs."runs_scored") AS "total_runs"
    FROM IPL.IPL.BATSMAN_SCORED bs
    JOIN IPL.IPL.BALL_BY_BALL bbb
        ON bs."match_id" = bbb."match_id"
        AND bs."innings_no" = bbb."innings_no"
        AND bs."over_id" = bbb."over_id"
        AND bs."ball_id" = bbb."ball_id"
    GROUP BY bbb."match_id", bbb."striker"
),
loser_players AS (
    SELECT 
        pm."player_id", 
        pm."team_id", 
        pm."match_id"
    FROM IPL.IPL.PLAYER_MATCH pm
    JOIN IPL.IPL.MATCH m
        ON pm."match_id" = m."match_id"
    WHERE pm."team_id" != m."match_winner"
)
SELECT DISTINCT 
    p."player_name", 
    ps."match_id", 
    ps."total_runs"
FROM player_scores ps
JOIN loser_players lp
    ON ps."match_id" = lp."match_id" AND ps."striker" = lp."player_id"
JOIN IPL.IPL.PLAYER p
    ON ps."striker" = p."player_id"
WHERE ps."total_runs" >= 100
ORDER BY ps."total_runs" DESC NULLS LAST
LIMIT 20;