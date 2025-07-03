WITH TeamHighestGoals AS (
    SELECT 
        "team_api_id",
        MAX("total_goals") AS "highest_goals"
    FROM (
        SELECT 
            "home_team_api_id" AS "team_api_id",
            SUM("home_team_goal") AS "total_goals"
        FROM EU_SOCCER.EU_SOCCER.MATCH
        GROUP BY "home_team_api_id", "season"
        UNION ALL
        SELECT 
            "away_team_api_id" AS "team_api_id",
            SUM("away_team_goal") AS "total_goals"
        FROM EU_SOCCER.EU_SOCCER.MATCH
        GROUP BY "away_team_api_id", "season"
    ) TeamGoals
    GROUP BY "team_api_id"
),
RankedGoals AS (
    SELECT
        "highest_goals",
        ROW_NUMBER() OVER (ORDER BY "highest_goals") AS "rank",
        COUNT(*) OVER () AS "total_teams"
    FROM TeamHighestGoals
)
SELECT 
    AVG("highest_goals") AS "median"
FROM RankedGoals
WHERE "rank" IN (
    (CASE WHEN MOD("total_teams", 2) = 0 THEN "total_teams" / 2 ELSE ("total_teams" + 1) / 2 END),
    (CASE WHEN MOD("total_teams", 2) = 0 THEN ("total_teams" / 2) + 1 ELSE ("total_teams" + 1) / 2 END)
);