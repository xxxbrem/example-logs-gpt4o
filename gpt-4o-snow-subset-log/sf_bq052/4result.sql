WITH FilteredCitations AS (
    -- Backward citations within 1 month before the application date
    SELECT 
        a."patent_id",
        COUNT(DISTINCT c."citation_id") AS backward_citations
    FROM PATENTSVIEW.PATENTSVIEW.APPLICATION a
    INNER JOIN PATENTSVIEW.PATENTSVIEW.USPATENTCITATION c
        ON a."patent_id" = c."citation_id"
    WHERE TRY_TO_DATE(c."date", 'YYYY-MM-DD') IS NOT NULL
      AND TRY_TO_DATE(a."date", 'YYYY-MM-DD') IS NOT NULL
      AND DATEDIFF(MONTH, TRY_TO_DATE(c."date", 'YYYY-MM-DD'), TRY_TO_DATE(a."date", 'YYYY-MM-DD')) = -1
    GROUP BY a."patent_id"
),
ForwardCitations AS (
    -- Forward citations within 1 month after the application date
    SELECT 
        a."patent_id",
        COUNT(DISTINCT c."citation_id") AS forward_citations
    FROM PATENTSVIEW.PATENTSVIEW.APPLICATION a
    INNER JOIN PATENTSVIEW.PATENTSVIEW.USPATENTCITATION c
        ON a."patent_id" = c."patent_id"
    WHERE TRY_TO_DATE(c."date", 'YYYY-MM-DD') IS NOT NULL
      AND TRY_TO_DATE(a."date", 'YYYY-MM-DD') IS NOT NULL
      AND DATEDIFF(MONTH, TRY_TO_DATE(a."date", 'YYYY-MM-DD'), TRY_TO_DATE(c."date", 'YYYY-MM-DD')) = 1
    GROUP BY a."patent_id"
),
FilteredPatents AS (
    -- Filter patents to include only those belonging to CPC subsection 'C05' or group 'A01G'
    SELECT DISTINCT 
        c."patent_id" 
    FROM PATENTSVIEW.PATENTSVIEW.CPC_CURRENT c
    WHERE c."subsection_id" = 'C05' OR c."group_id" = 'A01G'
),
PatentsWithCitations AS (
    -- Combine forward and backward citations with patent information
    SELECT 
        p."id" AS patent_id,
        p."title",
        TRY_TO_DATE(a."date", 'YYYY-MM-DD') AS application_date,
        COALESCE(bc.backward_citations, 0) AS backward_citation_count,
        COALESCE(fc.forward_citations, 0) AS forward_citation_count,
        p."abstract"
    FROM FilteredPatents fp
    INNER JOIN PATENTSVIEW.PATENTSVIEW.PATENT p
        ON fp."patent_id" = p."id"
    INNER JOIN PATENTSVIEW.PATENTSVIEW.APPLICATION a
        ON p."id" = a."patent_id"
    LEFT JOIN FilteredCitations bc
        ON p."id" = bc."patent_id"
    LEFT JOIN ForwardCitations fc
        ON p."id" = fc."patent_id"
    WHERE COALESCE(bc.backward_citations, 0) > 0 OR COALESCE(fc.forward_citations, 0) > 0
)
-- Final ordered results
SELECT *
FROM PatentsWithCitations
ORDER BY application_date ASC;