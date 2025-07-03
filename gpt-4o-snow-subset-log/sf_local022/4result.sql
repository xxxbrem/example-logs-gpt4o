WITH total_runs_per_match AS (
    SELECT 
        b."match_id", 
        b."striker" AS "player_id", 
        SUM(bs."runs_scored") AS "total_runs"
    FROM 
        IPL.IPL.BALL_BY_BALL b
    JOIN 
        IPL.IPL.BATSMAN_SCORED bs
    ON 
        b."match_id" = bs."match_id" 
        AND b."ball_id" = bs."ball_id"
    GROUP BY 
        b."match_id", 
        b."striker"
    HAVING 
        SUM(bs."runs_scored") >= 100
),
losing_team_players AS (
    SELECT 
        pm."match_id", 
        pm."player_id", 
        pm."team_id"
    FROM 
        IPL.IPL.PLAYER_MATCH pm
    WHERE 
        pm."team_id" IN (
            SELECT 
                CASE 
                    WHEN m."match_winner" = m."team_1" THEN m."team_2"
                    WHEN m."match_winner" = m."team_2" THEN m."team_1"
                END AS "losing_team_id"
            FROM 
                IPL.IPL.MATCH m
            WHERE 
                m."outcome_type" = 'Result'
        )
),
qualifying_players AS (
    SELECT 
        trpm."match_id", 
        trpm."player_id", 
        trpm."total_runs"
    FROM 
        total_runs_per_match trpm
    JOIN 
        losing_team_players ltp
    ON 
        trpm."match_id" = ltp."match_id"
        AND trpm."player_id" = ltp."player_id"
)
SELECT 
    p."player_name", 
    qp."total_runs", 
    qp."match_id"
FROM 
    qualifying_players qp
JOIN 
    IPL.IPL.PLAYER p
ON 
    qp."player_id" = p."player_id"
LIMIT 20;