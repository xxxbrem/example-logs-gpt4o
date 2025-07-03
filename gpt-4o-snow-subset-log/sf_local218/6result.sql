SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY "highest_season_goals") AS "median_highest_goals"
FROM (
    SELECT "team_api_id", MAX("season_goals") AS "highest_season_goals"
    FROM (
        SELECT "season", "team_api_id", SUM("total_goals") AS "season_goals"
        FROM (
            SELECT "season", "home_team_api_id" AS "team_api_id", SUM("home_team_goal") AS "total_goals"
            FROM "EU_SOCCER"."EU_SOCCER"."MATCH"
            GROUP BY "season", "home_team_api_id"
            UNION ALL
            SELECT "season", "away_team_api_id" AS "team_api_id", SUM("away_team_goal") AS "total_goals"
            FROM "EU_SOCCER"."EU_SOCCER"."MATCH"
            GROUP BY "season", "away_team_api_id"
        ) AS "team_goals"
        GROUP BY "season", "team_api_id"
    ) AS "season_max_goals"
    GROUP BY "team_api_id"
) AS "highest_goals";