WITH HomePoints AS (
    SELECT 
        "season", 
        "home_team_api_id" AS "team_api_id", 
        SUM(CASE 
            WHEN "home_team_goal" > "away_team_goal" THEN 3 
            WHEN "home_team_goal" = "away_team_goal" THEN 1 
            ELSE 0 
        END) AS "home_points"
    FROM "EU_SOCCER"."EU_SOCCER"."MATCH"
    GROUP BY "season", "home_team_api_id"
),
AwayPoints AS (
    SELECT 
        "season", 
        "away_team_api_id" AS "team_api_id", 
        SUM(CASE 
            WHEN "away_team_goal" > "home_team_goal" THEN 3 
            WHEN "away_team_goal" = "home_team_goal" THEN 1 
            ELSE 0 
        END) AS "away_points"
    FROM "EU_SOCCER"."EU_SOCCER"."MATCH"
    GROUP BY "season", "away_team_api_id"
),
TotalPoints AS (
    SELECT 
        h."season",
        h."team_api_id",
        (h."home_points" + COALESCE(a."away_points", 0)) AS "total_points"
    FROM HomePoints h
    LEFT JOIN AwayPoints a
    ON h."season" = a."season" AND h."team_api_id" = a."team_api_id"
),
TeamDetails AS (
    SELECT 
        t."team_long_name",
        tp."season",
        tp."total_points",
        l."name" AS "league_name",
        c."name" AS "country_name"
    FROM TotalPoints tp
    JOIN "EU_SOCCER"."EU_SOCCER"."TEAM" t
    ON tp."team_api_id" = t."team_api_id"
    JOIN "EU_SOCCER"."EU_SOCCER"."MATCH" m
    ON tp."season" = m."season" AND tp."team_api_id" IN (m."home_team_api_id", m."away_team_api_id")
    JOIN "EU_SOCCER"."EU_SOCCER"."LEAGUE" l
    ON m."league_id" = l."id"
    JOIN "EU_SOCCER"."EU_SOCCER"."COUNTRY" c
    ON l."country_id" = c."id"
),
ChampionTeams AS (
    SELECT 
        "season", 
        "team_long_name", 
        "league_name", 
        "country_name", 
        "total_points",
        ROW_NUMBER() OVER (PARTITION BY "season" ORDER BY "total_points" DESC NULLS LAST) AS "rank"
    FROM TeamDetails
)
SELECT 
    "season",
    "team_long_name" AS "champion_team",
    "league_name",
    "country_name",
    "total_points"
FROM ChampionTeams
WHERE "rank" = 1
ORDER BY "season";