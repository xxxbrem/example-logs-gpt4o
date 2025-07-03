WITH Stack_Max_Scores AS (
    -- Identify the maximum 'Stack' model test_score for each name, version, and step
    SELECT 
        "name", 
        "version", 
        "step", 
        MAX("test_score") AS "stack_score"
    FROM "STACKING"."STACKING"."MODEL_SCORE"
    WHERE "model" = 'Stack'
    GROUP BY "name", "version", "step"
),
Non_Stack_Max_Scores AS (
    -- Identify the maximum test_score of non-'Stack' models for each name, version, and step
    SELECT 
        "name", 
        "version", 
        "step", 
        MAX("test_score") AS "non_stack_score"
    FROM "STACKING"."STACKING"."MODEL_SCORE"
    WHERE "model" != 'Stack'
    GROUP BY "name", "version", "step"
),
Status_Classification AS (
    -- Combine 'Stack' and 'Non_Stack' scores to classify status ('strong' or 'soft')
    SELECT 
        s."name", 
        s."version", 
        s."step", 
        s."stack_score",
        ns."non_stack_score",
        CASE 
            WHEN ns."non_stack_score" < s."stack_score" THEN 'strong'
            WHEN ns."non_stack_score" = s."stack_score" THEN 'soft'
        END AS "status"
    FROM Stack_Max_Scores s
    JOIN Non_Stack_Max_Scores ns
    ON s."name" = ns."name" AND s."version" = ns."version" AND s."step" = ns."step"
),
L1_Model_Status_Count AS (
    -- Join with MODEL table to associate L1_model with each status and count occurrences
    SELECT 
        m."L1_model", 
        c."status", 
        COUNT(DISTINCT c."name", c."version", c."step") AS "count"
    FROM Status_Classification c
    JOIN "STACKING"."STACKING"."MODEL" m
    ON c."name" = m."name" AND c."version" = m."version"
    WHERE c."status" IS NOT NULL
    GROUP BY m."L1_model", c."status"
),
Max_Status_L1_Models AS (
    -- Determine the L1_model with the highest occurrence for each status
    SELECT 
        "status",
        "L1_model",
        "count"
    FROM (
        SELECT 
            "status",
            "L1_model",
            "count",
            RANK() OVER (PARTITION BY "status" ORDER BY "count" DESC NULLS LAST) AS "rank"
        FROM L1_Model_Status_Count
    ) 
    WHERE "rank" = 1
)
-- Final output with L1_model having the highest occurrence for each status
SELECT 
    "status", 
    "L1_model", 
    "count"
FROM Max_Status_L1_Models;