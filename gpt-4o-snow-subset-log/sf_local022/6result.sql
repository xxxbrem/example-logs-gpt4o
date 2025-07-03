SELECT DISTINCT
    p."player_name",
    t4."total_runs",
    pt."name" AS "team_name",
    mt."name" AS "opponent_team_name",
    t4."match_id"
FROM IPL.IPL.PLAYER p
JOIN (
    SELECT 
        t2."match_id",
        t2."player_id",
        t2."total_runs",
        bb."team_batting" AS "player_team",
        m."match_winner"
    FROM IPL.IPL.MATCH m
    JOIN IPL.IPL.BALL_BY_BALL bb
        ON m."match_id" = bb."match_id"
    JOIN (
        SELECT 
            bb."match_id", 
            bb."striker" AS "player_id", 
            SUM(bs."runs_scored") AS "total_runs"
        FROM IPL.IPL.BALL_BY_BALL bb
        JOIN IPL.IPL.BATSMAN_SCORED bs
            ON bb."match_id" = bs."match_id"
            AND bb."ball_id" = bs."ball_id"
        GROUP BY bb."match_id", bb."striker"
    ) t2
        ON bb."match_id" = t2."match_id"
        AND bb."striker" = t2."player_id"
    WHERE t2."total_runs" >= 100
      AND bb."team_batting" != m."match_winner"
) t4
    ON p."player_id" = t4."player_id"
JOIN IPL.IPL.TEAM pt
    ON t4."player_team" = pt."team_id"
JOIN IPL.IPL.TEAM mt
    ON t4."match_winner" = mt."team_id";