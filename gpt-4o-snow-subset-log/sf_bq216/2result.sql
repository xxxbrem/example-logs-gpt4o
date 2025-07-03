WITH TargetPatentEmbedding AS (
    SELECT "publication_number", "embedding_v1"
    FROM PATENTS_GOOGLE.PATENTS_GOOGLE.ABS_AND_EMB
    WHERE "publication_number" = 'US-9741766-B2'
),
FlattenedTargetEmbedding AS (
    SELECT 
        "publication_number", 
        value::FLOAT AS target_value, 
        INDEX AS vector_index
    FROM TargetPatentEmbedding, 
    TABLE(FLATTEN(input => "embedding_v1"))
),
SimilarPatents AS (
    SELECT 
        ae."publication_number",
        SUM(ft.target_value * CAST(f.value AS FLOAT)) AS similarity
    FROM 
        PATENTS_GOOGLE.PATENTS_GOOGLE.ABS_AND_EMB ae,
        LATERAL FLATTEN(input => ae."embedding_v1") f
    INNER JOIN 
        FlattenedTargetEmbedding ft
    ON 
        f.INDEX = ft.vector_index
    WHERE 
        ae."publication_number" IN (
            SELECT "publication_number"
            FROM PATENTS_GOOGLE.PATENTS_GOOGLE.PUBLICATIONS
            WHERE "filing_date" LIKE '2015%'
        )
    GROUP BY 
        ae."publication_number"
)
SELECT "publication_number"
FROM SimilarPatents
ORDER BY similarity DESC NULLS LAST
LIMIT 5;