WITH Over_Run_Summary AS (
  SELECT b."match_id", b."bowler", b."innings_no", b."over_id", 
         SUM(COALESCE(s."runs_scored", 0) + COALESCE(e."extra_runs", 0)) AS "total_runs"
  FROM IPL.IPL.BALL_BY_BALL b
  LEFT JOIN IPL.IPL.BATSMAN_SCORED s 
    ON b."match_id" = s."match_id" 
    AND b."innings_no" = s."innings_no" 
    AND b."over_id" = s."over_id" 
    AND b."ball_id" = s."ball_id"
  LEFT JOIN IPL.IPL.EXTRA_RUNS e
    ON b."match_id" = e."match_id" 
    AND b."innings_no" = e."innings_no" 
    AND b."over_id" = e."over_id" 
    AND b."ball_id" = e."ball_id"
  GROUP BY b."match_id", b."bowler", b."innings_no", b."over_id"
),
Max_Runs_Per_Match AS (
  SELECT o."match_id", o."bowler", o."innings_no", o."over_id", o."total_runs"
  FROM Over_Run_Summary o
  WHERE o."total_runs" = (
    SELECT MAX(inner_o."total_runs")
    FROM Over_Run_Summary inner_o
    WHERE inner_o."match_id" = o."match_id"
  )
),
Top_3_Bowlers AS (
  SELECT DISTINCT t."match_id", t."bowler", t."total_runs"
  FROM Max_Runs_Per_Match t
  ORDER BY t."total_runs" DESC NULLS LAST
  LIMIT 3
)
SELECT t3."match_id", t3."total_runs", p."player_name" AS "bowler_name"
FROM Top_3_Bowlers t3
JOIN IPL.IPL.PLAYER p
  ON t3."bowler" = p."player_id";