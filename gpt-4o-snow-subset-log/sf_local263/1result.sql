WITH Model_Status AS (
    SELECT s."name", s."version", s."step", 
           MAX(CASE WHEN n."test_score" < s."test_score" THEN 'strong' 
                    WHEN n."test_score" = s."test_score" THEN 'soft' 
                    ELSE NULL END) AS "status"
    FROM "STACKING"."STACKING"."MODEL_SCORE" s 
    INNER JOIN "STACKING"."STACKING"."MODEL_SCORE" n 
        ON s."name" = n."name" AND s."version" = n."version" AND s."step" = n."step"
    WHERE s."model" ILIKE '%Stack%' AND n."model" NOT ILIKE '%Stack%'
    GROUP BY s."name", s."version", s."step"
), L1_Model_Count AS (
    SELECT m."L1_model", ms."status", COUNT(*) AS "count"
    FROM Model_Status ms 
    INNER JOIN "STACKING"."STACKING"."MODEL" m 
        ON ms."name" = m."name" AND ms."version" = m."version" AND ms."step" = m."step"
    GROUP BY m."L1_model", ms."status"
)
SELECT "L1_model", "status", MAX("count") AS "max_count"
FROM L1_Model_Count
GROUP BY "L1_model", "status"
ORDER BY "status", "max_count" DESC NULLS LAST
LIMIT 20;