WITH TeamPoints AS (
  -- Calculate total points for home teams
  SELECT 
    m."season",
    m."league_id",
    m."country_id",
    m."home_team_api_id" AS "team_api_id",
    SUM(CASE 
          WHEN m."home_team_goal" > m."away_team_goal" THEN 3
          WHEN m."home_team_goal" = m."away_team_goal" THEN 1
          ELSE 0
        END) AS "total_points"
  FROM "EU_SOCCER"."EU_SOCCER"."MATCH" m
  GROUP BY m."season", m."league_id", m."country_id", m."home_team_api_id"
  
  UNION ALL
  
  -- Calculate total points for away teams
  SELECT 
    m."season",
    m."league_id",
    m."country_id",
    m."away_team_api_id" AS "team_api_id",
    SUM(CASE 
          WHEN m."away_team_goal" > m."home_team_goal" THEN 3
          WHEN m."home_team_goal" = m."away_team_goal" THEN 1
          ELSE 0
        END) AS "total_points"
  FROM "EU_SOCCER"."EU_SOCCER"."MATCH" m
  GROUP BY m."season", m."league_id", m."country_id", m."away_team_api_id"
),

AggregatedPoints AS (
  -- Aggregate total points per team per season, league, and country
  SELECT 
    tp."season",
    tp."league_id",
    tp."country_id",
    tp."team_api_id",
    SUM(tp."total_points") AS "total_points"
  FROM TeamPoints tp
  GROUP BY tp."season", tp."league_id", tp."country_id", tp."team_api_id"
),

ChampionTeams AS (
  -- Identify the team with the maximum points for each season, league, and country
  SELECT 
    ap."season",
    ap."league_id",
    ap."country_id",
    ap."team_api_id",
    ap."total_points",
    RANK() OVER (PARTITION BY ap."season", ap."league_id", ap."country_id" ORDER BY ap."total_points" DESC NULLS LAST) AS "rank"
  FROM AggregatedPoints ap
),

FilteredChampionTeams AS (
  -- Filter only the champions (rank = 1) for each season, league, and country
  SELECT 
    ct."season",
    ct."league_id",
    ct."country_id",
    ct."team_api_id",
    ct."total_points"
  FROM ChampionTeams ct
  WHERE ct."rank" = 1
),

ChampionDetails AS (
  -- Join champions with TEAM, LEAGUE, and COUNTRY tables to get readable information
  SELECT 
    fct."season",
    l."name" AS "league_name",
    c."name" AS "country_name",
    t."team_long_name" AS "team_name",
    fct."total_points"
  FROM FilteredChampionTeams fct
  LEFT JOIN "EU_SOCCER"."EU_SOCCER"."TEAM" t ON fct."team_api_id" = t."team_api_id"
  LEFT JOIN "EU_SOCCER"."EU_SOCCER"."LEAGUE" l ON fct."league_id" = l."id"
  LEFT JOIN "EU_SOCCER"."EU_SOCCER"."COUNTRY" c ON fct."country_id" = c."id"
)

-- Final selection: Return champions details
SELECT 
  "season",
  "league_name",
  "country_name",
  "team_name",
  "total_points"
FROM ChampionDetails
ORDER BY "season", "country_name", "league_name";