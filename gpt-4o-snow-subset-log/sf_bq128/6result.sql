SELECT 
    p."title" AS "patent_title",
    p."abstract" AS "patent_abstract",
    p."date" AS "publication_date",
    COUNT(DISTINCT bc."citation_id") AS "backward_citations",
    COUNT(DISTINCT fc."patent_id") AS "forward_citations_within_5_years"
FROM 
    PATENTSVIEW.PATENTSVIEW.PATENT p
LEFT JOIN 
    PATENTSVIEW.PATENTSVIEW.USPATENTCITATION bc 
    ON p."id" = bc."patent_id" AND bc."date" < p."date"
LEFT JOIN 
    PATENTSVIEW.PATENTSVIEW.USPATENTCITATION fc 
    ON p."id" = fc."citation_id" AND fc."date" BETWEEN p."date" AND DATEADD(year, 5, p."date")
WHERE 
    p."country" = 'US' 
    AND p."date" BETWEEN '2014-01-01' AND '2014-02-01'
GROUP BY 
    p."id", p."title", p."abstract", p."date"
LIMIT 20;