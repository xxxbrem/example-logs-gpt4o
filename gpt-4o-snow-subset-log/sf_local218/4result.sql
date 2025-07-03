WITH TeamGoals AS (
    SELECT COALESCE(home."team_api_id", away."team_api_id") AS "team_api_id", 
           COALESCE(home."season", away."season") AS "season", 
           COALESCE(home."season_home_goals", 0) + COALESCE(away."season_away_goals", 0) AS "total_season_goals"
    FROM (
        SELECT "home_team_api_id" AS "team_api_id", 
               "season", 
               SUM("home_team_goal") AS "season_home_goals"
        FROM "EU_SOCCER"."EU_SOCCER"."MATCH"
        GROUP BY "home_team_api_id", "season"
    ) home
    FULL OUTER JOIN (
        SELECT "away_team_api_id" AS "team_api_id", 
               "season", 
               SUM("away_team_goal") AS "season_away_goals"
        FROM "EU_SOCCER"."EU_SOCCER"."MATCH"
        GROUP BY "away_team_api_id", "season"
    ) away
    ON home."team_api_id" = away."team_api_id" AND home."season" = away."season"
),
HighestSeasonGoals AS (
    SELECT "team_api_id", 
           MAX("total_season_goals") AS "highest_season_goals"
    FROM TeamGoals
    GROUP BY "team_api_id"
)
SELECT MEDIAN("highest_season_goals") AS "median_highest_season_goals"
FROM HighestSeasonGoals;