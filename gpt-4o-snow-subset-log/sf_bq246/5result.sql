WITH BackwardCitations AS (
    SELECT 
        ut."patent_id", 
        COUNT(ut."citation_id") AS backward_citation_count
    FROM "PATENTSVIEW"."PATENTSVIEW"."USPATENTCITATION" ut
    JOIN "PATENTSVIEW"."PATENTSVIEW"."APPLICATION" ap
        ON ut."patent_id" = ap."patent_id"
    WHERE TRY_CAST(ut."date" AS DATE) IS NOT NULL 
        AND TRY_CAST(ap."date" AS DATE) IS NOT NULL
        AND DATEDIFF('year', TRY_CAST(ap."date" AS DATE), TRY_CAST(ut."date" AS DATE)) <= 1
    GROUP BY ut."patent_id"
),
ForwardCitations AS (
    SELECT 
        ut."citation_id", 
        COUNT(ut."patent_id") AS forward_citation_count
    FROM "PATENTSVIEW"."PATENTSVIEW"."USPATENTCITATION" ut
    JOIN "PATENTSVIEW"."PATENTSVIEW"."APPLICATION" ap
        ON ut."citation_id" = ap."patent_id"
    WHERE TRY_CAST(ut."date" AS DATE) IS NOT NULL 
        AND TRY_CAST(ap."date" AS DATE) IS NOT NULL
        AND DATEDIFF('year', TRY_CAST(ap."date" AS DATE), TRY_CAST(ut."date" AS DATE)) <= 3
    GROUP BY ut."citation_id"
),
MostBackwardPatent AS (
    SELECT 
        bc."patent_id" 
    FROM BackwardCitations bc
    ORDER BY bc.backward_citation_count DESC NULLS LAST
    LIMIT 1
),
Result AS (
    SELECT 
        mbp."patent_id", 
        bc.backward_citation_count, 
        COALESCE(fc.forward_citation_count, 0) AS forward_citation_count
    FROM MostBackwardPatent mbp
    LEFT JOIN BackwardCitations bc
        ON mbp."patent_id" = bc."patent_id"
    LEFT JOIN ForwardCitations fc
        ON mbp."patent_id" = fc."citation_id"
)
SELECT "patent_id", backward_citation_count, forward_citation_count 
FROM Result;