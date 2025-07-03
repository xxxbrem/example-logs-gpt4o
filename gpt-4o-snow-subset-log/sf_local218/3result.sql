SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY "highest_goals_season") AS "median_highest_goals"
FROM (
  SELECT "team_api_id", MAX("total_season_goals") AS "highest_goals_season"
  FROM (
    SELECT "season", "home_team_api_id" AS "team_api_id", SUM("home_team_goal") + SUM("away_team_goal") AS "total_season_goals"
    FROM "EU_SOCCER"."EU_SOCCER"."MATCH"
    GROUP BY "season", "home_team_api_id", "away_team_api_id"
  ) goals
  GROUP BY "team_api_id"
) sub;