WITH StrongModels AS (
    SELECT m."L1_model", COUNT(*) AS "strong_count"
    FROM "STACKING"."STACKING"."MODEL" m
    JOIN (
        SELECT sm."name", sm."version", sm."step"
        FROM (
            SELECT "name", "version", "step", "test_score"
            FROM "STACKING"."STACKING"."MODEL_SCORE"
            WHERE "model" ILIKE '%Stack%'
        ) sm
        JOIN (
            SELECT "name", "version", "step", MAX("test_score") AS "max_non_stack_test_score"
            FROM "STACKING"."STACKING"."MODEL_SCORE"
            WHERE "model" NOT ILIKE '%Stack%'
            GROUP BY "name", "version", "step"
        ) nsm
        ON sm."name" = nsm."name" AND sm."version" = nsm."version" AND sm."step" = nsm."step"
        WHERE sm."test_score" > nsm."max_non_stack_test_score"
    ) s
    ON m."name" = s."name" AND m."version" = s."version" AND m."step" = s."step"
    GROUP BY m."L1_model"
),
SoftModels AS (
    SELECT m."L1_model", COUNT(*) AS "soft_count"
    FROM "STACKING"."STACKING"."MODEL" m
    JOIN (
        SELECT sm."name", sm."version", sm."step"
        FROM (
            SELECT "name", "version", "step", "test_score"
            FROM "STACKING"."STACKING"."MODEL_SCORE"
            WHERE "model" ILIKE '%Stack%'
        ) sm
        JOIN (
            SELECT "name", "version", "step", MAX("test_score") AS "max_non_stack_test_score"
            FROM "STACKING"."STACKING"."MODEL_SCORE"
            WHERE "model" NOT ILIKE '%Stack%'
            GROUP BY "name", "version", "step"
        ) nsm
        ON sm."name" = nsm."name" AND sm."version" = nsm."version" AND sm."step" = nsm."step"
        WHERE sm."test_score" = nsm."max_non_stack_test_score"
    ) s
    ON m."name" = s."name" AND m."version" = s."version" AND m."step" = s."step"
    GROUP BY m."L1_model"
),
MaxStrongModel AS (
    SELECT 
        'strong' AS "status",
        "L1_model",
        "strong_count" AS "count"
    FROM StrongModels
    ORDER BY "strong_count" DESC NULLS LAST
    LIMIT 1
),
MaxSoftModel AS (
    SELECT 
        'soft' AS "status",
        "L1_model",
        "soft_count" AS "count"
    FROM SoftModels
    ORDER BY "soft_count" DESC NULLS LAST
    LIMIT 1
)
SELECT * FROM MaxStrongModel
UNION ALL
SELECT * FROM MaxSoftModel;