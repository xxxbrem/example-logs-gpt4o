WITH match_results AS (
    -- Calculate match results for home and away teams separately
    SELECT 
        "league_id",
        "season",
        "home_team_api_id" AS "team_api_id", 
        CASE 
            WHEN "home_team_goal" > "away_team_goal" THEN 'win' 
            WHEN "home_team_goal" = "away_team_goal" THEN 'draw' 
            ELSE 'loss' 
        END AS "result"
    FROM "EU_SOCCER"."EU_SOCCER"."MATCH"
    
    UNION ALL
    
    SELECT 
        "league_id",
        "season",
        "away_team_api_id" AS "team_api_id", 
        CASE 
            WHEN "away_team_goal" > "home_team_goal" THEN 'win' 
            WHEN "away_team_goal" = "home_team_goal" THEN 'draw' 
            ELSE 'loss' 
        END AS "result"
    FROM "EU_SOCCER"."EU_SOCCER"."MATCH"
),
league_points AS (
    -- Aggregate total points for each team based on match results
    SELECT 
        "league_id",
        "season",
        "team_api_id",
        SUM(
            CASE 
                WHEN "result" = 'win' THEN 3 
                WHEN "result" = 'draw' THEN 1 
                ELSE 0 
            END
        ) AS "total_points"
    FROM match_results
    GROUP BY "league_id", "season", "team_api_id"
),
ranked_teams AS (
    -- Rank teams within each league and season by total points
    SELECT 
        "league_id",
        "season",
        "team_api_id",
        "total_points",
        RANK() OVER (
            PARTITION BY "league_id", "season" 
            ORDER BY "total_points" DESC NULLS LAST
        ) AS "rank"
    FROM league_points
)
-- Fetch the champion teams, their league, country, and total points
SELECT 
    t."team_long_name" AS "champion_team",
    c."name" AS "country_name",
    l."name" AS "league_name",
    rt."season",
    rt."total_points"
FROM ranked_teams rt
JOIN "EU_SOCCER"."EU_SOCCER"."TEAM" t
    ON rt."team_api_id" = t."team_api_id"
JOIN "EU_SOCCER"."EU_SOCCER"."LEAGUE" l
    ON rt."league_id" = l."id"
JOIN "EU_SOCCER"."EU_SOCCER"."COUNTRY" c
    ON l."country_id" = c."id"
WHERE rt."rank" = 1
ORDER BY rt."season", c."name", l."name"
LIMIT 20;