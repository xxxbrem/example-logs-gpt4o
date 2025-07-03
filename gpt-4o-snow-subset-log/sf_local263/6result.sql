WITH non_stack_scores AS (
    SELECT "name", "version", MAX("test_score") AS "max_non_stack_test_score"
    FROM STACKING.STACKING.MODEL_SCORE
    WHERE "model" NOT ILIKE '%Stack%'
    GROUP BY "name", "version"
),
stack_scores AS (
    SELECT "name", "version", "test_score" AS "stack_test_score"
    FROM STACKING.STACKING.MODEL_SCORE
    WHERE "model" ILIKE '%Stack%'
),
status_data AS (
    SELECT m."L1_model",
           CASE 
               WHEN ns."max_non_stack_test_score" < ss."stack_test_score" THEN 'strong'
               WHEN ns."max_non_stack_test_score" = ss."stack_test_score" THEN 'soft'
           END AS "status"
    FROM STACKING.STACKING.MODEL m
    JOIN non_stack_scores ns
    ON m."name" = ns."name" AND m."version" = ns."version"
    JOIN stack_scores ss
    ON m."name" = ss."name" AND m."version" = ss."version"
),
status_counts AS (
    SELECT "L1_model", "status", COUNT(*) AS "status_count"
    FROM status_data
    WHERE "status" IS NOT NULL
    GROUP BY "L1_model", "status"
)
SELECT "L1_model", "status", "status_count"
FROM status_counts
QUALIFY ROW_NUMBER() OVER (PARTITION BY "status" ORDER BY "status_count" DESC NULLS LAST) = 1;