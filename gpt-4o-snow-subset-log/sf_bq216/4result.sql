WITH TARGET_PATENT AS (
    SELECT "embedding_v1" AS target_embedding
    FROM "PATENTS_GOOGLE"."PATENTS_GOOGLE"."ABS_AND_EMB"
    WHERE "publication_number" = 'US-9741766-B2'
),
FILING_YEAR AS (
    SELECT "filing_date"
    FROM "PATENTS_GOOGLE"."PATENTS_GOOGLE"."PUBLICATIONS"
    WHERE "publication_number" = 'US-9741766-B2'
),
SAME_YEAR_PATENTS AS (
    SELECT 
        a."publication_number", 
        b."embedding_v1"
    FROM "PATENTS_GOOGLE"."PATENTS_GOOGLE"."PUBLICATIONS" a
    JOIN "PATENTS_GOOGLE"."PATENTS_GOOGLE"."ABS_AND_EMB" b
    ON a."publication_number" = b."publication_number"
    WHERE a."filing_date" = (SELECT "filing_date" FROM FILING_YEAR) AND b."embedding_v1" IS NOT NULL
),
TARGET_EMBEDDING_VALUES AS (
    SELECT VALUE AS target_value, SEQ AS target_seq
    FROM LATERAL FLATTEN(input => (SELECT target_embedding FROM TARGET_PATENT))
),
SIMILARITY_SCORES AS (
    SELECT 
        p."publication_number",
        SUM(CAST(t.target_value AS FLOAT) * CAST(e.value AS FLOAT)) AS similarity
    FROM SAME_YEAR_PATENTS p,
    LATERAL FLATTEN(input => p."embedding_v1") e,
    TARGET_EMBEDDING_VALUES t
    WHERE e.SEQ = t.target_seq
    GROUP BY p."publication_number"
)
SELECT "publication_number"
FROM SIMILARITY_SCORES
ORDER BY similarity DESC NULLS LAST
LIMIT 5;