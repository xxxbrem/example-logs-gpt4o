WITH team_goals AS (
    SELECT 
        "season",
        "home_team_api_id" AS "team_api_id",
        SUM("home_team_goal") AS "total_goals"
    FROM "EU_SOCCER"."EU_SOCCER"."MATCH"
    GROUP BY "season", "home_team_api_id"
    UNION ALL
    SELECT 
        "season",
        "away_team_api_id" AS "team_api_id",
        SUM("away_team_goal") AS "total_goals"
    FROM "EU_SOCCER"."EU_SOCCER"."MATCH"
    GROUP BY "season", "away_team_api_id"
),
highest_goals AS (
    SELECT "team_api_id", MAX("total_goals") AS "highest_season_goals"
    FROM team_goals
    GROUP BY "team_api_id"
),
ranked_goals AS (
    SELECT "highest_season_goals", ROW_NUMBER() OVER (ORDER BY "highest_season_goals") AS "row_num"
    FROM highest_goals
),
total_teams AS (
    SELECT COUNT(*) AS "team_count"
    FROM ranked_goals
)
SELECT 
    AVG("highest_season_goals") AS "median_highest_season_goals"
FROM ranked_goals r
JOIN total_teams t
ON r."row_num" IN ((t."team_count" + 1)/2, (t."team_count" + 2)/2);