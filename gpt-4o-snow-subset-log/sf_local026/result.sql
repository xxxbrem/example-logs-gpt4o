WITH Max_Runs_Over_Per_Match AS (
    -- Step 1: Calculate the total runs (scored + extras) per over per match and identify the overs with the maximum runs conceded in each match
    SELECT 
        bb."match_id", 
        bb."innings_no", 
        bb."over_id", 
        bb."bowler", 
        (SUM(bs."runs_scored") + COALESCE(SUM(er."extra_runs"), 0)) AS "total_runs"
    FROM 
        IPL.IPL.BALL_BY_BALL bb
    LEFT JOIN 
        IPL.IPL.BATSMAN_SCORED bs
    ON 
        bb."match_id" = bs."match_id" 
        AND bb."innings_no" = bs."innings_no" 
        AND bb."over_id" = bs."over_id" 
        AND bb."ball_id" = bs."ball_id"
    LEFT JOIN 
        IPL.IPL.EXTRA_RUNS er
    ON 
        bb."match_id" = er."match_id" 
        AND bb."innings_no" = er."innings_no" 
        AND bb."over_id" = er."over_id" 
        AND bb."ball_id" = er."ball_id"
    GROUP BY 
        bb."match_id", 
        bb."innings_no", 
        bb."over_id", 
        bb."bowler"
),
Max_Overs_Per_Match AS (
    -- Step 2: Identify the maximum runs conceded in a single over for each match
    SELECT 
        "match_id", 
        MAX("total_runs") AS "max_runs"
    FROM 
        Max_Runs_Over_Per_Match
    GROUP BY 
        "match_id"
),
Overs_With_Max_Runs AS (
    -- Step 3: Join the results from Step 1 and Step 2 to get the overs where maximum runs were conceded in each match
    SELECT 
        t1."match_id", 
        t1."innings_no", 
        t1."over_id", 
        t1."bowler", 
        t1."total_runs"
    FROM 
        Max_Runs_Over_Per_Match t1
    INNER JOIN 
        Max_Overs_Per_Match t2
    ON 
        t1."match_id" = t2."match_id" 
        AND t1."total_runs" = t2."max_runs"
),
Top_3_Bowlers AS (
    -- Step 4: Select the top 3 bowlers who conceded the most runs across all matches
    SELECT 
        ow."match_id", 
        ow."innings_no", 
        ow."over_id", 
        p."player_name" AS "bowler_name", 
        ow."total_runs"
    FROM 
        Overs_With_Max_Runs ow
    LEFT JOIN 
        IPL.IPL.PLAYER p
    ON 
        ow."bowler" = p."player_id"
    ORDER BY 
        ow."total_runs" DESC NULLS LAST
    LIMIT 3
)
-- Step 5: Output the results
SELECT 
    "match_id", 
    "innings_no", 
    "over_id", 
    "bowler_name", 
    "total_runs"
FROM 
    Top_3_Bowlers;