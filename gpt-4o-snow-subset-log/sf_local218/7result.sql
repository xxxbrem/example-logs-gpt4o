WITH highest_goals AS (
    SELECT "team_api_id", MAX("total_season_goals") AS "highest_season_goals"
    FROM (
        SELECT 
            COALESCE(home."team_api_id", away."team_api_id") AS "team_api_id",
            COALESCE(home."season", away."season") AS "season",
            COALESCE(home."total_home_goals", 0) + COALESCE(away."total_away_goals", 0) AS "total_season_goals"
        FROM
            (SELECT "season", "home_team_api_id" AS "team_api_id", SUM("home_team_goal") AS "total_home_goals"
             FROM "EU_SOCCER"."EU_SOCCER"."MATCH"
             GROUP BY "season", "home_team_api_id") home
        FULL JOIN
            (SELECT "season", "away_team_api_id" AS "team_api_id", SUM("away_team_goal") AS "total_away_goals"
             FROM "EU_SOCCER"."EU_SOCCER"."MATCH"
             GROUP BY "season", "away_team_api_id") away
        ON home."team_api_id" = away."team_api_id" AND home."season" = away."season"
    ) subquery
    GROUP BY "team_api_id"
)
SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY "highest_season_goals") AS "median_highest_season_goals"
FROM highest_goals;