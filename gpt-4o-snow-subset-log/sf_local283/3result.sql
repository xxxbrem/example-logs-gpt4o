WITH team_results AS (
  -- Aggregate points for all teams across wins and draws
  SELECT 
      t."team_long_name" AS "team_name",
      l."name" AS "league_name",
      c."name" AS "country_name",
      agg_points."season",
      agg_points."total_points"
  FROM (
      SELECT 
          "team_api_id", 
          "season", 
          "league_id", 
          SUM("points") AS "total_points"
      FROM (
          -- Points for home wins
          SELECT "home_team_api_id" AS "team_api_id", "season", "league_id", 3 AS "points" 
          FROM EU_SOCCER.EU_SOCCER.MATCH 
          WHERE "home_team_goal" > "away_team_goal"
          UNION ALL 
          -- Points for away wins
          SELECT "away_team_api_id" AS "team_api_id", "season", "league_id", 3 AS "points" 
          FROM EU_SOCCER.EU_SOCCER.MATCH 
          WHERE "away_team_goal" > "home_team_goal"
          UNION ALL 
          -- Points for home draws
          SELECT "home_team_api_id" AS "team_api_id", "season", "league_id", 1 AS "points" 
          FROM EU_SOCCER.EU_SOCCER.MATCH 
          WHERE "home_team_goal" = "away_team_goal"
          UNION ALL 
          -- Points for away draws
          SELECT "away_team_api_id" AS "team_api_id", "season", "league_id", 1 AS "points" 
          FROM EU_SOCCER.EU_SOCCER.MATCH 
          WHERE "home_team_goal" = "away_team_goal"
      ) AS points_calculation 
      GROUP BY "team_api_id", "season", "league_id"
  ) AS agg_points 
  -- Join team names
  JOIN EU_SOCCER.EU_SOCCER.TEAM t ON agg_points."team_api_id" = t."team_api_id" 
  -- Join league names
  JOIN EU_SOCCER.EU_SOCCER.LEAGUE l ON agg_points."league_id" = l."id" 
  -- Join country names
  JOIN EU_SOCCER.EU_SOCCER.COUNTRY c ON l."country_id" = c."id"
),
champion_teams AS (
  -- Find the champion team for each league and season
  SELECT 
      "team_name",
      "league_name",
      "country_name",
      "season",
      "total_points",
      ROW_NUMBER() OVER (PARTITION BY "league_name", "season" ORDER BY "total_points" DESC NULLS LAST) AS "rank"
  FROM team_results
)
-- Select only the champion (rank = 1)
SELECT 
    "team_name", 
    "league_name", 
    "country_name", 
    "season", 
    "total_points" 
FROM champion_teams 
WHERE "rank" = 1;