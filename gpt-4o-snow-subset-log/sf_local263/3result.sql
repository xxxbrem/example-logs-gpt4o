WITH stack_status AS (
    -- Determine the status (strong/soft) for each 'Stack' model
    SELECT a."name", a."version", a."step", 
           CASE 
               WHEN a."test_score" > b."max_non_stack_score" THEN 'strong'
               WHEN a."test_score" = b."max_non_stack_score" THEN 'soft'
               ELSE NULL
           END AS "status"
    FROM "STACKING"."STACKING"."MODEL_SCORE" a
    JOIN (
        -- Identify the maximum test score of non-'Stack' models for each (name, version, step)
        SELECT "name", "version", "step", MAX("test_score") AS "max_non_stack_score" 
        FROM "STACKING"."STACKING"."MODEL_SCORE" 
        WHERE "model" NOT ILIKE '%Stack%' 
        GROUP BY "name", "version", "step"
    ) b
    ON a."name" = b."name" AND a."version" = b."version" AND a."step" = b."step" 
    WHERE a."model" ILIKE '%Stack%'
),
status_counts AS (
    -- Count occurrences of each L1_model for strong/soft status
    SELECT t1."name", t1."version", t2."L1_model", t1."status", COUNT(*) AS "status_count"
    FROM stack_status t1
    JOIN "STACKING"."STACKING"."MODEL" t2
    ON t1."name" = t2."name" AND t1."version" = t2."version"
    GROUP BY t1."name", t1."version", t2."L1_model", t1."status"
),
max_occurrences AS (
    -- Find the maximum occurrence for each status per L1_model
    SELECT "status", "L1_model", SUM("status_count") AS "total_count"
    FROM status_counts
    WHERE "status" IS NOT NULL
    GROUP BY "status", "L1_model"
)
-- Determine the L1_model with the highest occurrence for each status
SELECT "status", "L1_model", MAX("total_count") AS "max_occurrence"
FROM max_occurrences
GROUP BY "status", "L1_model"
ORDER BY "status", "max_occurrence" DESC NULLS LAST;