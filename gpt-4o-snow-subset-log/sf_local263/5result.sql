WITH Strong_L1_Model_Count AS (
    SELECT 
        m."L1_model", COUNT(*) AS "status_count", 'strong' AS "status"
    FROM (
        SELECT 
            ms."name", 
            ms."version", 
            ms."step", 
            ms."test_score" AS "stack_score", 
            ns."max_non_stack_score"
        FROM "STACKING"."STACKING"."MODEL_SCORE" ms
        JOIN (
            SELECT 
                "name", 
                "version", 
                "step", 
                MAX("test_score") AS "max_non_stack_score"
            FROM "STACKING"."STACKING"."MODEL_SCORE"
            WHERE "model" NOT ILIKE '%Stack%'
            GROUP BY "name", "version", "step"
        ) ns
        ON ms."name" = ns."name" AND ms."version" = ns."version" AND ms."step" = ns."step"
        WHERE ms."model" ILIKE '%Stack%' AND ms."test_score" > ns."max_non_stack_score"
    ) strong
    JOIN "STACKING"."STACKING"."MODEL" m
    ON strong."name" = m."name" AND strong."version" = m."version" AND strong."step" = m."step"
    GROUP BY m."L1_model"
),
Soft_L1_Model_Count AS (
    SELECT 
        m."L1_model", COUNT(*) AS "status_count", 'soft' AS "status"
    FROM (
        SELECT 
            ms."name", 
            ms."version", 
            ms."step", 
            ms."test_score" AS "stack_score", 
            ns."max_non_stack_score"
        FROM "STACKING"."STACKING"."MODEL_SCORE" ms
        JOIN (
            SELECT 
                "name", 
                "version", 
                "step", 
                MAX("test_score") AS "max_non_stack_score"
            FROM "STACKING"."STACKING"."MODEL_SCORE"
            WHERE "model" NOT ILIKE '%Stack%'
            GROUP BY "name", "version", "step"
        ) ns
        ON ms."name" = ns."name" AND ms."version" = ns."version" AND ms."step" = ns."step"
        WHERE ms."model" ILIKE '%Stack%' AND ms."test_score" = ns."max_non_stack_score"
    ) soft
    JOIN "STACKING"."STACKING"."MODEL" m
    ON soft."name" = m."name" AND soft."version" = m."version" AND soft."step" = m."step"
    GROUP BY m."L1_model"
),
Combined_Status_Counts AS (
    SELECT * 
    FROM Strong_L1_Model_Count
    UNION ALL
    SELECT * 
    FROM Soft_L1_Model_Count
)
SELECT 
    "status", 
    "L1_model", 
    MAX("status_count") AS "max_occurrence"
FROM Combined_Status_Counts
GROUP BY "status", "L1_model"
ORDER BY "status", "max_occurrence" DESC NULLS LAST
LIMIT 20;