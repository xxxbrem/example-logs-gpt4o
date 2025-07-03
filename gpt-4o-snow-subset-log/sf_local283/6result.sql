WITH home_points AS (
    SELECT 
        "home_team_api_id" AS "team_api_id", 
        "season", 
        "league_id", 
        "country_id", 
        SUM(
            CASE 
                WHEN "home_team_goal" > "away_team_goal" THEN 3 
                WHEN "home_team_goal" = "away_team_goal" THEN 1 
                ELSE 0 
            END
        ) AS "points"
    FROM "EU_SOCCER"."EU_SOCCER"."MATCH"
    GROUP BY "home_team_api_id", "season", "league_id", "country_id"
), 
away_points AS (
    SELECT 
        "away_team_api_id" AS "team_api_id", 
        "season", 
        "league_id", 
        "country_id", 
        SUM(
            CASE 
                WHEN "away_team_goal" > "home_team_goal" THEN 3 
                WHEN "away_team_goal" = "home_team_goal" THEN 1 
                ELSE 0 
            END
        ) AS "points"
    FROM "EU_SOCCER"."EU_SOCCER"."MATCH"
    GROUP BY "away_team_api_id", "season", "league_id", "country_id"
), 
total_points AS (
    SELECT 
        "team_api_id", 
        "season", 
        "league_id", 
        "country_id", 
        SUM("points") AS "total_points"
    FROM (
        SELECT * FROM home_points
        UNION ALL
        SELECT * FROM away_points
    ) AS points_union
    GROUP BY "team_api_id", "season", "league_id", "country_id"
), 
max_points_per_season AS (
    SELECT 
        "season", 
        "league_id", 
        "country_id", 
        MAX("total_points") AS "max_points"
    FROM total_points
    GROUP BY "season", "league_id", "country_id"
), 
champions AS (
    SELECT 
        tp."team_api_id", 
        tp."season", 
        tp."league_id", 
        tp."country_id", 
        tp."total_points"
    FROM total_points tp
    JOIN max_points_per_season mps
    ON tp."season" = mps."season" 
        AND tp."league_id" = mps."league_id" 
        AND tp."country_id" = mps."country_id" 
        AND tp."total_points" = mps."max_points"
)
SELECT 
    champions."season", 
    teams."team_long_name" AS "champion_team", 
    leagues."name" AS "league", 
    countries."name" AS "country", 
    champions."total_points" AS "total_points"
FROM champions
JOIN "EU_SOCCER"."EU_SOCCER"."TEAM" AS teams
    ON champions."team_api_id" = teams."team_api_id"
JOIN "EU_SOCCER"."EU_SOCCER"."LEAGUE" AS leagues
    ON champions."league_id" = leagues."id"
JOIN "EU_SOCCER"."EU_SOCCER"."COUNTRY" AS countries
    ON champions."country_id" = countries."id"
ORDER BY champions."season", champions."total_points" DESC NULLS LAST
LIMIT 20;