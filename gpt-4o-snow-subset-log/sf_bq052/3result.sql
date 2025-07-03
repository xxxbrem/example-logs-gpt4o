SELECT DISTINCT 
    p."id" AS "patent_id", 
    p."title", 
    ap."date" AS "application_date", 
    p."abstract" AS "abstract_text",
    COALESCE(backward_citation_count.citation_count, 0) AS backward_citation_count,
    COALESCE(forward_citation_count.citation_count, 0) AS forward_citation_count
FROM 
    PATENTSVIEW.PATENTSVIEW.PATENT p
JOIN 
    PATENTSVIEW.PATENTSVIEW.APPLICATION ap
ON 
    p."id" = ap."patent_id"
JOIN 
    PATENTSVIEW.PATENTSVIEW.CPC_CURRENT cc
ON 
    p."id" = cc."patent_id"
LEFT JOIN 
    (
        SELECT 
            uc."patent_id", 
            COUNT(DISTINCT uc."citation_id") AS citation_count
        FROM 
            PATENTSVIEW.PATENTSVIEW.USPATENTCITATION uc
        JOIN 
            PATENTSVIEW.PATENTSVIEW.APPLICATION ap
        ON 
            uc."citation_id" = ap."patent_id"
        WHERE 
            TRY_TO_DATE(uc."date", 'YYYY-MM-DD') IS NOT NULL AND
            TRY_TO_DATE(ap."date", 'YYYY-MM-DD') IS NOT NULL AND
            DATE(uc."date") BETWEEN DATEADD(day, -30, DATE(ap."date")) AND DATE(ap."date")
        GROUP BY 
            uc."patent_id"
    ) AS backward_citation_count
ON 
    p."id" = backward_citation_count."patent_id"
LEFT JOIN 
    (
        SELECT 
            uc."patent_id", 
            COUNT(DISTINCT uc."citation_id") AS citation_count
        FROM 
            PATENTSVIEW.PATENTSVIEW.USPATENTCITATION uc
        JOIN 
            PATENTSVIEW.PATENTSVIEW.APPLICATION ap
        ON 
            uc."patent_id" = ap."patent_id"
        WHERE 
            TRY_TO_DATE(uc."date", 'YYYY-MM-DD') IS NOT NULL AND
            TRY_TO_DATE(ap."date", 'YYYY-MM-DD') IS NOT NULL AND
            DATE(uc."date") BETWEEN DATE(ap."date") AND DATEADD(day, 30, DATE(ap."date"))
        GROUP BY 
            uc."patent_id"
    ) AS forward_citation_count
ON 
    p."id" = forward_citation_count."patent_id"
WHERE 
    TRY_TO_DATE(ap."date", 'YYYY-MM-DD') IS NOT NULL AND
    (cc."subsection_id" = 'C05' OR cc."group_id" = 'A01G') AND
    (COALESCE(backward_citation_count.citation_count, 0) > 0 OR COALESCE(forward_citation_count.citation_count, 0) > 0)
ORDER BY 
    ap."date"