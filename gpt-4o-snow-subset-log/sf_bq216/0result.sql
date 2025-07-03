WITH patent_embeddings AS (
  SELECT 
      t1."publication_number", 
      t1."publication_date", 
      t2."embedding_v1"
  FROM 
      PATENTS_GOOGLE.PATENTS_GOOGLE.PUBLICATIONS t1
  JOIN 
      PATENTS_GOOGLE.PATENTS_GOOGLE.ABS_AND_EMB t2
  ON 
      t1."publication_number" = t2."publication_number"
  WHERE 
      t1."publication_date" BETWEEN 20170101 AND 20171231
),
target_embedding AS (
  SELECT 
      t2."embedding_v1" AS target_vector
  FROM 
      PATENTS_GOOGLE.PATENTS_GOOGLE.PUBLICATIONS t1
  JOIN 
      PATENTS_GOOGLE.PATENTS_GOOGLE.ABS_AND_EMB t2
  ON 
      t1."publication_number" = t2."publication_number"
  WHERE 
      t1."publication_number" = 'US-9741766-B2'
),
similarity_scores AS (
  SELECT 
      p."publication_number", 
      SUM(CAST(t_unnested.value AS FLOAT) * CAST(p_unnested.value AS FLOAT)) AS similarity_score
  FROM 
      patent_embeddings p
  CROSS JOIN 
      target_embedding target,
      LATERAL FLATTEN(input => p."embedding_v1") AS p_unnested,
      LATERAL FLATTEN(input => target.target_vector) AS t_unnested
  WHERE 
      p_unnested.INDEX = t_unnested.INDEX AND 
      p."publication_number" != 'US-9741766-B2' -- Exclude the target patent
  GROUP BY 
      p."publication_number"
)
SELECT 
    "publication_number"
FROM 
    similarity_scores
ORDER BY 
    similarity_score DESC NULLS LAST
LIMIT 
    5;