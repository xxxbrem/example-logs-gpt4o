SELECT DISTINCT 
    p."player_name", 
    t_final."match_id", 
    t_final."total_runs", 
    team_lost."name" AS "team_name"
FROM (
    SELECT 
        t1."match_id", 
        t1."striker", 
        t1."total_runs", 
        t3."team_id" AS "losing_team_id", 
        t2."match_winner"
    FROM (
        -- Aggregate total runs per striker per match
        SELECT 
            bs."match_id", 
            bb."striker", 
            SUM(bs."runs_scored") AS "total_runs"
        FROM IPL.IPL."BATSMAN_SCORED" bs
        JOIN IPL.IPL."BALL_BY_BALL" bb
        ON bs."match_id" = bb."match_id"
           AND bs."over_id" = bb."over_id"
           AND bs."ball_id" = bb."ball_id"
        GROUP BY 
            bs."match_id", 
            bb."striker"
    ) t1
    LEFT JOIN IPL.IPL."MATCH" t2
    ON t1."match_id" = t2."match_id"
    LEFT JOIN IPL.IPL."PLAYER_MATCH" t3
    ON t1."match_id" = t3."match_id" 
       AND t1."striker" = t3."player_id"
    -- Filter players with at least 100 runs and whose team lost the match
    WHERE t1."total_runs" >= 100 
      AND t3."team_id" <> t2."match_winner"
) t_final
LEFT JOIN IPL.IPL."PLAYER" p
ON t_final."striker" = p."player_id"
LEFT JOIN IPL.IPL."TEAM" team_lost
ON t_final."losing_team_id" = team_lost."team_id"
LIMIT 20;