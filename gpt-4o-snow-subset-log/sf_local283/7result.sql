WITH match_points AS (
    -- Calculate match points for both home and away teams
    SELECT 
        "season", 
        "league_id", 
        "home_team_api_id" AS "team_api_id", 
        CASE 
            WHEN "home_team_goal" > "away_team_goal" THEN 3 
            WHEN "home_team_goal" = "away_team_goal" THEN 1 
            ELSE 0 
        END AS "points"
    FROM EU_SOCCER.EU_SOCCER.MATCH
    UNION ALL
    SELECT 
        "season", 
        "league_id", 
        "away_team_api_id" AS "team_api_id", 
        CASE 
            WHEN "away_team_goal" > "home_team_goal" THEN 3 
            WHEN "away_team_goal" = "home_team_goal" THEN 1 
            ELSE 0 
        END AS "points"
    FROM EU_SOCCER.EU_SOCCER.MATCH
),
total_team_points AS (
    -- Aggregate total points for each team by season and league
    SELECT 
        "season", 
        "league_id", 
        "team_api_id", 
        SUM("points") AS "total_points"
    FROM match_points
    GROUP BY "season", "league_id", "team_api_id"
),
champions AS (
    -- Determine the champion team for each season and league
    SELECT 
        tp."season", 
        tp."league_id", 
        tp."team_api_id", 
        t."team_long_name", 
        tp."total_points"
    FROM total_team_points tp
    JOIN EU_SOCCER.EU_SOCCER.TEAM t
    ON tp."team_api_id" = t."team_api_id"
    WHERE (tp."season", tp."league_id", tp."total_points") IN (
        SELECT "season", "league_id", MAX("total_points")
        FROM total_team_points
        GROUP BY "season", "league_id"
    )
)
-- Combine champion details with league and country information
SELECT 
    c."name" AS "country_name", 
    l."name" AS "league_name", 
    ch."season", 
    ch."team_long_name" AS "champion_team", 
    ch."total_points"
FROM champions ch
JOIN EU_SOCCER.EU_SOCCER.LEAGUE l
ON ch."league_id" = l."id"
JOIN EU_SOCCER.EU_SOCCER.COUNTRY c
ON l."country_id" = c."id"
ORDER BY ch."season" ASC, c."name" ASC, l."name" ASC;