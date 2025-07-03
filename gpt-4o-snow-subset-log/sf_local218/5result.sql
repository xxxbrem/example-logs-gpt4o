WITH "highest_goals" AS (
    SELECT "team_api_id", MAX("total_season_goals") AS "highest_season_goals"
    FROM (
        SELECT "season", "team_api_id", 
               SUM("season_goals") AS "total_season_goals"
        FROM (
            SELECT "season", "home_team_api_id" AS "team_api_id", 
                   SUM("home_team_goal") AS "season_goals"
            FROM "EU_SOCCER"."EU_SOCCER"."MATCH"
            GROUP BY "season", "home_team_api_id"
            UNION ALL
            SELECT "season", "away_team_api_id" AS "team_api_id", 
                   SUM("away_team_goal") AS "season_goals"
            FROM "EU_SOCCER"."EU_SOCCER"."MATCH"
            GROUP BY "season", "away_team_api_id"
        ) AS "team_goals"
        GROUP BY "season", "team_api_id"
    ) AS "team_season_totals"
    GROUP BY "team_api_id"
)
-- Use NTILE to split the records into two equal halves for median calculation
SELECT AVG("highest_season_goals") AS "median_highest_goals"
FROM (
    SELECT "highest_season_goals", NTILE(2) OVER (ORDER BY "highest_season_goals") AS "tile"
    FROM "highest_goals"
) AS "goal_tiles"
WHERE "tile" = 1 OR "tile" = 2;