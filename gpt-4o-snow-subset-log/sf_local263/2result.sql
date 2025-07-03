SELECT 
    mdl."L1_model", 
    mdl."name", 
    mdl."version", 
    mdl_statuses."status", 
    COUNT(*) AS "status_count"
FROM "STACKING"."STACKING"."MODEL" mdl
JOIN (
    SELECT 
        stack_scores."name", 
        stack_scores."version", 
        stack_scores."step",
        CASE 
            WHEN stack_scores."stack_score" > non_stack_scores."max_non_stack_score" THEN 'strong'
            WHEN stack_scores."stack_score" = non_stack_scores."max_non_stack_score" THEN 'soft'
        END AS "status"
    FROM (
        SELECT "name", "version", "step", "test_score" AS "stack_score"
        FROM "STACKING"."STACKING"."MODEL_SCORE"
        WHERE "model" ILIKE '%Stack%'
    ) stack_scores
    JOIN (
        SELECT "name", "version", "step", MAX("test_score") AS "max_non_stack_score"
        FROM "STACKING"."STACKING"."MODEL_SCORE"
        WHERE "model" NOT ILIKE '%Stack%'
        GROUP BY "name", "version", "step"
    ) non_stack_scores
    ON stack_scores."name" = non_stack_scores."name"
       AND stack_scores."version" = non_stack_scores."version"
       AND stack_scores."step" = non_stack_scores."step"
) mdl_statuses
ON mdl."name" = mdl_statuses."name" 
   AND mdl."version" = mdl_statuses."version"
GROUP BY mdl."L1_model", mdl."name", mdl."version", mdl_statuses."status"
ORDER BY "status_count" DESC NULLS LAST
LIMIT 20;