SELECT 
    p."id" AS patent_id, 
    p."title", 
    app."date" AS application_date, 
    COUNT(DISTINCT bwd."citation_id") AS num_backward_citations, 
    COUNT(DISTINCT fwd."patent_id") AS num_forward_citations, 
    p."abstract" 
FROM 
    PATENTSVIEW.PATENTSVIEW.PATENT p
JOIN 
    PATENTSVIEW.PATENTSVIEW.CPC_CURRENT cpc
    ON p."id" = cpc."patent_id"
JOIN 
    PATENTSVIEW.PATENTSVIEW.APPLICATION app
    ON p."id" = app."patent_id" AND
       TRY_TO_DATE(app."date", 'YYYY-MM-DD') IS NOT NULL
LEFT JOIN 
    PATENTSVIEW.PATENTSVIEW.USPATENTCITATION bwd
    ON p."id" = bwd."citation_id" AND 
       bwd."date" IS NOT NULL AND 
       TRY_TO_DATE(bwd."date", 'YYYY-MM-DD') IS NOT NULL AND 
       ABS(DATEDIFF(DAY, TRY_TO_DATE(bwd."date", 'YYYY-MM-DD'), TRY_TO_DATE(app."date", 'YYYY-MM-DD'))) <= 30
LEFT JOIN 
    PATENTSVIEW.PATENTSVIEW.USPATENTCITATION fwd
    ON p."id" = fwd."patent_id" AND 
       fwd."date" IS NOT NULL AND 
       TRY_TO_DATE(fwd."date", 'YYYY-MM-DD') IS NOT NULL AND 
       ABS(DATEDIFF(DAY, TRY_TO_DATE(fwd."date", 'YYYY-MM-DD'), TRY_TO_DATE(app."date", 'YYYY-MM-DD'))) <= 30
WHERE 
    p."country" = 'US' AND 
    (cpc."subsection_id" = 'C05' OR cpc."group_id" = 'A01G')
GROUP BY 
    p."id", p."title", app."date", p."abstract"
HAVING 
    COUNT(DISTINCT bwd."citation_id") > 0 OR COUNT(DISTINCT fwd."patent_id") > 0
ORDER BY 
    app."date" ASC;