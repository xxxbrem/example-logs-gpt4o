WITH Patent_Embeddings AS (
    SELECT 
        a."publication_number", 
        a."embedding_v1"
    FROM 
        PATENTS_GOOGLE.PATENTS_GOOGLE.ABS_AND_EMB a
    JOIN 
        PATENTS_GOOGLE.PATENTS_GOOGLE.PUBLICATIONS p
    ON 
        a."publication_number" = p."publication_number"
    WHERE 
        p."filing_date" >= 20150101 AND p."filing_date" <= 20151231
), 
Target_Embedding AS (
    SELECT 
        "embedding_v1"
    FROM 
        PATENTS_GOOGLE.PATENTS_GOOGLE.ABS_AND_EMB
    WHERE 
        "publication_number" = 'US-9741766-B2'
), 
Exploded_Target_Embedding AS (
    SELECT 
        t.index AS target_index, 
        t.value AS target_value
    FROM 
        Target_Embedding, 
        LATERAL FLATTEN(input => Target_Embedding."embedding_v1") t
), 
Exploded_Patent_Embeddings AS (
    SELECT 
        e."publication_number", 
        e2.index AS embedding_index, 
        e2.value AS embedding_value
    FROM 
        Patent_Embeddings e, 
        LATERAL FLATTEN(input => e."embedding_v1") e2
), 
Similarity_Scores AS (
    SELECT 
        epe."publication_number", 
        SUM(epe.embedding_value * ete.target_value) AS similarity_score
    FROM 
        Exploded_Patent_Embeddings epe
    JOIN 
        Exploded_Target_Embedding ete
    ON 
        epe.embedding_index = ete.target_index
    GROUP BY 
        epe."publication_number"
)
SELECT 
    "publication_number"
FROM 
    Similarity_Scores
ORDER BY 
    similarity_score DESC NULLS LAST
LIMIT 5;