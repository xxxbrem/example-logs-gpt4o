SELECT 
    p."player_name",
    t."match_id",
    t."total_runs",
    m."team_1" AS "team_1_id",
    m."team_2" AS "team_2_id",
    m."match_winner"
FROM (
    SELECT 
        bs."match_id",
        bb."team_batting" AS "team_id",
        bb."striker",
        SUM(bs."runs_scored") AS "total_runs"
    FROM IPL.IPL.BATSMAN_SCORED bs
    JOIN IPL.IPL.BALL_BY_BALL bb 
        ON bs."match_id" = bb."match_id" 
        AND bs."ball_id" = bb."ball_id"
    GROUP BY 
        bs."match_id", 
        bb."team_batting", 
        bb."striker"
    HAVING SUM(bs."runs_scored") >= 100
) t
JOIN IPL.IPL.MATCH m 
    ON t."match_id" = m."match_id"
JOIN IPL.IPL.PLAYER p
    ON t."striker" = p."player_id"
WHERE t."team_id" != m."match_winner";