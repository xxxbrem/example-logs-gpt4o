SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY "highest_season_goals") AS "median_highest_season_goals"
FROM (
  SELECT MAX("season_goals") AS "highest_season_goals"
  FROM (
    SELECT "home_team_api_id" AS "team_api_id", "season", 
           SUM("home_team_goal") AS "season_goals"
    FROM "EU_SOCCER"."EU_SOCCER"."MATCH" 
    GROUP BY "home_team_api_id", "season"
    UNION ALL
    SELECT "away_team_api_id" AS "team_api_id", "season", 
           SUM("away_team_goal") AS "season_goals"
    FROM "EU_SOCCER"."EU_SOCCER"."MATCH" 
    GROUP BY "away_team_api_id", "season"
  ) AS "team_season_goals"
  GROUP BY "team_api_id"
) AS "highest_team_goals";