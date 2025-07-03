WITH BackwardCitations AS (
    -- Retrieve the number of backward citations within 1 year before the application date
    SELECT 
        "p1"."id" AS "patent_id",
        COUNT("uc"."citation_id") AS "backward_citations_count"
    FROM 
        "PATENTSVIEW"."PATENTSVIEW"."PATENT" AS "p1"
    JOIN 
        "PATENTSVIEW"."PATENTSVIEW"."APPLICATION" AS "a"
        ON "p1"."id" = "a"."patent_id"
    JOIN 
        "PATENTSVIEW"."PATENTSVIEW"."USPATENTCITATION" AS "uc"
        ON "uc"."citation_id" = "p1"."number"
    WHERE 
        TRY_TO_DATE("uc"."date", 'YYYY-MM-DD') < TRY_TO_DATE("a"."date", 'YYYY-MM-DD') 
        AND DATEDIFF(year, TRY_TO_DATE("uc"."date", 'YYYY-MM-DD'), TRY_TO_DATE("a"."date", 'YYYY-MM-DD')) <= 1
    GROUP BY 
        "p1"."id"
),
ForwardCitations AS (
    -- Retrieve the number of forward citations within 1 year after the application date
    SELECT 
        "p2"."id" AS "patent_id",
        COUNT("uc"."patent_id") AS "forward_citations_count"
    FROM 
        "PATENTSVIEW"."PATENTSVIEW"."PATENT" AS "p2"
    JOIN 
        "PATENTSVIEW"."PATENTSVIEW"."APPLICATION" AS "a"
        ON "p2"."id" = "a"."patent_id"
    JOIN 
        "PATENTSVIEW"."PATENTSVIEW"."USPATENTCITATION" AS "uc"
        ON "uc"."citation_id" = "p2"."number"
    WHERE 
        TRY_TO_DATE("uc"."date", 'YYYY-MM-DD') > TRY_TO_DATE("a"."date", 'YYYY-MM-DD') 
        AND DATEDIFF(year, TRY_TO_DATE("a"."date", 'YYYY-MM-DD'), TRY_TO_DATE("uc"."date", 'YYYY-MM-DD')) <= 1
    GROUP BY 
        "p2"."id"
),
CPCFilteredPatents AS (
    -- Filter patents by specific CPC categories
    SELECT DISTINCT 
        "cc"."patent_id"
    FROM 
        "PATENTSVIEW"."PATENTSVIEW"."CPC_CURRENT" AS "cc"
    WHERE 
        "cc"."category" = 'inventional'
)
-- Combine the results and retrieve the top patent
SELECT 
    "b"."patent_id",
    "b"."backward_citations_count",
    "f"."forward_citations_count"
FROM 
    BackwardCitations AS "b"
JOIN 
    ForwardCitations AS "f"
    ON "b"."patent_id" = "f"."patent_id"
JOIN 
    CPCFilteredPatents AS "cpc"
    ON "b"."patent_id" = "cpc"."patent_id"
ORDER BY 
    "b"."backward_citations_count" DESC NULLS LAST
LIMIT 1;