SELECT 
    p."id" AS "patent_id",
    p."title",
    p."abstract",
    p."date" AS "publication_date",
    COALESCE(COUNT(DISTINCT backward."citation_id"), 0) AS "backward_citation_count",
    COALESCE(COUNT(DISTINCT forward."patent_id"), 0) AS "forward_citation_count"
FROM 
    PATENTSVIEW.PATENTSVIEW.PATENT p
LEFT JOIN 
    PATENTSVIEW.PATENTSVIEW.USPATENTCITATION backward
    ON p."id" = backward."patent_id" 
    AND backward."date" < p."date"
LEFT JOIN 
    PATENTSVIEW.PATENTSVIEW.USPATENTCITATION forward
    ON p."id" = forward."citation_id" 
    AND forward."date" < DATEADD(YEAR, 5, p."date")
WHERE 
    p."date" >= '2014-01-01' 
    AND p."date" < '2014-02-01'
GROUP BY 
    p."id", p."title", p."abstract", p."date"
LIMIT 20;