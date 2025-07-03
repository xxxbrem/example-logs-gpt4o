SELECT 
    p."id" AS patent_id,
    p."title",
    p."abstract",
    p."date" AS publication_date,
    COUNT(DISTINCT bc."citation_id") AS backward_citation_count,
    COUNT(DISTINCT fc."citation_id") AS forward_citation_count
FROM PATENTSVIEW.PATENTSVIEW.PATENT p
LEFT JOIN PATENTSVIEW.PATENTSVIEW.USPATENTCITATION bc 
    ON p."id" = bc."patent_id" AND bc."date" < p."date"
LEFT JOIN PATENTSVIEW.PATENTSVIEW.USPATENTCITATION fc 
    ON p."id" = fc."citation_id" AND fc."date" >= p."date" 
    AND fc."date" < DATEADD(year, 5, p."date")
WHERE p."date" >= '2014-01-01' AND p."date" < '2014-02-01' AND p."country" = 'US'
GROUP BY p."id", p."title", p."abstract", p."date"
ORDER BY p."date" ASC NULLS LAST;