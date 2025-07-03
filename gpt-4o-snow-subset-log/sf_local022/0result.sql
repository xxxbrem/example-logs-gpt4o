SELECT DISTINCT 
    p."player_name"
FROM IPL.IPL."PLAYER" p
JOIN (
    SELECT 
        bb."striker"
    FROM IPL.IPL."BALL_BY_BALL" bb
    JOIN IPL.IPL."BATSMAN_SCORED" bs 
        ON bb."match_id" = bs."match_id" AND bb."ball_id" = bs."ball_id"
    JOIN IPL.IPL."MATCH" m
        ON bb."match_id" = m."match_id"
    GROUP BY 
        bb."striker", bb."team_batting", m."match_winner", bb."match_id"
    HAVING 
        SUM(bs."runs_scored") >= 100 
        AND bb."team_batting" != m."match_winner"
) subquery 
ON p."player_id" = subquery."striker";