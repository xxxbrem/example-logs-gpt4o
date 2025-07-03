WITH TeamPoints AS (
    SELECT 
        t."team_long_name", 
        m."league_id", 
        m."season", 
        SUM(
            CASE 
                WHEN m."home_team_api_id" = t."team_api_id" AND m."home_team_goal" > m."away_team_goal" THEN 3
                WHEN m."away_team_api_id" = t."team_api_id" AND m."away_team_goal" > m."home_team_goal" THEN 3
                WHEN (m."home_team_api_id" = t."team_api_id" OR m."away_team_api_id" = t."team_api_id")
                     AND m."home_team_goal" = m."away_team_goal" THEN 1
                ELSE 0
            END
        ) AS "total_points"
    FROM EU_SOCCER.EU_SOCCER.MATCH m
    JOIN EU_SOCCER.EU_SOCCER.TEAM t
        ON m."home_team_api_id" = t."team_api_id" OR m."away_team_api_id" = t."team_api_id"
    GROUP BY t."team_long_name", m."league_id", m."season"
),
ChampionTeams AS (
    SELECT 
        tp."team_long_name" AS "champion_team", 
        l."name" AS "league_name", 
        c."name" AS "country_name", 
        tp."season", 
        tp."total_points"
    FROM TeamPoints tp
    JOIN EU_SOCCER.EU_SOCCER.LEAGUE l
        ON tp."league_id" = l."id"
    JOIN EU_SOCCER.EU_SOCCER.COUNTRY c
        ON l."country_id" = c."id"
    QUALIFY RANK() OVER (PARTITION BY tp."season", tp."league_id" ORDER BY tp."total_points" DESC NULLS LAST) = 1
)
SELECT 
    "champion_team", 
    "league_name", 
    "country_name", 
    "season", 
    "total_points"
FROM ChampionTeams
ORDER BY "season", "country_name", "league_name";