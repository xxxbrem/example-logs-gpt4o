WITH Stack_Status AS (
    -- Determine status ('strong' or 'soft') for Stack models
    SELECT 
        s."name", 
        s."version", 
        s."step", 
        s."test_score" AS "stack_score", 
        non_stack."max_non_stack_score",
        CASE 
            WHEN s."test_score" > non_stack."max_non_stack_score" THEN 'strong'
            WHEN s."test_score" = non_stack."max_non_stack_score" THEN 'soft'
        END AS "status"
    FROM 
        (SELECT "name", "version", "step", "test_score", "model"
         FROM "STACKING"."STACKING"."MODEL_SCORE"
         WHERE "model" ILIKE '%Stack%') s
    LEFT JOIN 
        (SELECT "name", "version", "step", MAX("test_score") AS "max_non_stack_score"
         FROM "STACKING"."STACKING"."MODEL_SCORE"
         WHERE "model" NOT ILIKE '%Stack%'
         GROUP BY "name", "version", "step") non_stack
    ON s."name" = non_stack."name" AND s."version" = non_stack."version" AND s."step" = non_stack."step"
), L1_Model_Status_Count AS (
    -- Count occurrences of each L1_model for each status ('strong' or 'soft')
    SELECT 
        m."L1_model", 
        status_data."status", 
        COUNT(*) AS "count"
    FROM Stack_Status status_data
    JOIN "STACKING"."STACKING"."MODEL" m
    ON status_data."name" = m."name" AND status_data."version" = m."version" AND status_data."step" = m."step"
    WHERE status_data."status" IS NOT NULL
    GROUP BY m."L1_model", status_data."status"
)
-- Retrieve the L1_model with the highest occurrence for each status along with counts
SELECT 
    "L1_model", 
    "status", 
    MAX("count") AS "max_count"
FROM L1_Model_Status_Count
GROUP BY "L1_model", "status"
ORDER BY "status", "max_count" DESC NULLS LAST;