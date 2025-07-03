SELECT DISTINCT 
    p."player_name", 
    bb."match_id", 
    bb."total_runs", 
    t."team_batting" AS "losing_team_id", 
    tm."name" AS "losing_team_name"
FROM (
    SELECT 
        b."match_id", 
        b."innings_no", 
        b."striker", 
        SUM(bs."runs_scored") AS "total_runs"
    FROM IPL.IPL.BALL_BY_BALL b
    JOIN IPL.IPL.BATSMAN_SCORED bs
    ON b."match_id" = bs."match_id" 
       AND b."innings_no" = bs."innings_no" 
       AND b."ball_id" = bs."ball_id"
    GROUP BY b."match_id", b."innings_no", b."striker"
    HAVING SUM(bs."runs_scored") >= 100
) bb
JOIN IPL.IPL.MATCH m
ON bb."match_id" = m."match_id"
JOIN IPL.IPL.BALL_BY_BALL t
ON t."match_id" = bb."match_id" 
   AND t."team_batting" != m."match_winner"
JOIN IPL.IPL.PLAYER p
ON bb."striker" = p."player_id"
JOIN IPL.IPL.TEAM tm
ON t."team_batting" = tm."team_id"
LIMIT 20;