SELECT 
    tp."season", 
    MAX(t."team_long_name") AS "champion_team", 
    MAX(l."name") AS "league_name", 
    MAX(c."name") AS "country_name", 
    MAX(tp."total_points") AS "total_points" 
FROM (
    SELECT 
        "league_id", 
        "season", 
        "team_api_id", 
        SUM("points") AS "total_points" 
    FROM (
        SELECT 
            "league_id", 
            "season", 
            "home_team_api_id" AS "team_api_id", 
            CASE 
                WHEN "home_team_goal" > "away_team_goal" THEN 3 
                WHEN "home_team_goal" = "away_team_goal" THEN 1 
                ELSE 0 
            END AS "points" 
        FROM "EU_SOCCER"."EU_SOCCER"."MATCH"
        UNION ALL
        SELECT 
            "league_id", 
            "season", 
            "away_team_api_id" AS "team_api_id", 
            CASE 
                WHEN "away_team_goal" > "home_team_goal" THEN 3 
                WHEN "away_team_goal" = "home_team_goal" THEN 1 
                ELSE 0 
            END AS "points" 
        FROM "EU_SOCCER"."EU_SOCCER"."MATCH"
    ) AS team_points
    GROUP BY "league_id", "season", "team_api_id"
) tp
INNER JOIN "EU_SOCCER"."EU_SOCCER"."TEAM" t 
ON tp."team_api_id" = t."team_api_id"
INNER JOIN "EU_SOCCER"."EU_SOCCER"."LEAGUE" l 
ON tp."league_id" = l."id"
INNER JOIN "EU_SOCCER"."EU_SOCCER"."COUNTRY" c 
ON l."country_id" = c."id"
GROUP BY tp."season"
ORDER BY tp."season", "total_points" DESC NULLS LAST
LIMIT 20;