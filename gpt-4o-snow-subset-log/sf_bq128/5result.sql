SELECT 
    p."title", 
    p."abstract", 
    p."date" AS "publication_date", 
    COUNT(DISTINCT b."citation_id") AS "backward_citation_count", 
    COUNT(DISTINCT f."citation_id") AS "forward_citation_count_5yr"
FROM 
    PATENTSVIEW.PATENTSVIEW.PATENT p
LEFT JOIN 
    PATENTSVIEW.PATENTSVIEW.USPATENTCITATION b 
    ON p."id" = b."patent_id" AND b."date" < p."date"
LEFT JOIN 
    PATENTSVIEW.PATENTSVIEW.USPATENTCITATION f 
    ON p."id" = f."citation_id" 
    AND f."date" >= p."date" 
    AND f."date" < DATEADD(year, 5, p."date")
WHERE 
    p."country" = 'US' 
    AND p."date" >= '2014-01-01' 
    AND p."date" < '2014-02-01'
GROUP BY 
    p."title", 
    p."abstract", 
    p."date"
LIMIT 20;