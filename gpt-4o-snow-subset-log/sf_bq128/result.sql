WITH backward_citations AS (
    SELECT 
        p."id" AS patent_id,
        COUNT(c."citation_id") AS backward_count
    FROM 
        PATENTSVIEW.PATENTSVIEW.PATENT p
    LEFT JOIN 
        PATENTSVIEW.PATENTSVIEW.USPATENTCITATION c
    ON 
        p."id" = c."patent_id"
    WHERE 
        p."country" = 'US' 
        AND p."date" >= '2014-01-01' 
        AND p."date" < '2014-02-01'
        AND c."date" < p."date"
    GROUP BY 
        p."id"
),
forward_citations AS (
    SELECT 
        p."id" AS patent_id,
        COUNT(c."uuid") AS forward_count_within_5_years
    FROM 
        PATENTSVIEW.PATENTSVIEW.PATENT p
    LEFT JOIN 
        PATENTSVIEW.PATENTSVIEW.USPATENTCITATION c
    ON 
        c."citation_id" = p."id"
    WHERE 
        p."country" = 'US' 
        AND p."date" >= '2014-01-01' 
        AND p."date" < '2014-02-01'
        AND c."date" >= p."date" 
        AND c."date" < DATEADD(YEAR, 5, p."date")
    GROUP BY 
        p."id"
)
SELECT 
    p."id" AS patent_id,
    p."title" AS patent_title,
    p."abstract" AS patent_abstract,
    p."date" AS publication_date,
    COALESCE(bc.backward_count, 0) AS backward_citations,
    COALESCE(fc.forward_count_within_5_years, 0) AS forward_citations_within_5_years
FROM 
    PATENTSVIEW.PATENTSVIEW.PATENT p
LEFT JOIN 
    backward_citations bc
ON 
    p."id" = bc.patent_id
LEFT JOIN 
    forward_citations fc
ON 
    p."id" = fc.patent_id
WHERE 
    p."country" = 'US' 
    AND p."date" >= '2014-01-01' 
    AND p."date" < '2014-02-01';