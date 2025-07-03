WITH backward_citations AS (
    SELECT 
        p."id" AS "patent_id",
        COUNT(bwd."patent_id") AS "backward_citation_count"
    FROM PATENTSVIEW.PATENTSVIEW.PATENT p
    JOIN PATENTSVIEW.PATENTSVIEW.USPATENTCITATION bwd
        ON p."id" = bwd."citation_id"
    JOIN PATENTSVIEW.PATENTSVIEW.APPLICATION app
        ON p."id" = app."patent_id"
    WHERE TRY_TO_DATE(bwd."date", 'YYYY-MM-DD') IS NOT NULL
      AND TRY_TO_DATE(bwd."date", 'YYYY-MM-DD') >= DATEADD(MONTH, -1, app."date")
      AND TRY_TO_DATE(bwd."date", 'YYYY-MM-DD') < app."date"
    GROUP BY p."id"
),
forward_citations AS (
    SELECT 
        p."id" AS "patent_id",
        COUNT(fwd."citation_id") AS "forward_citation_count"
    FROM PATENTSVIEW.PATENTSVIEW.PATENT p
    JOIN PATENTSVIEW.PATENTSVIEW.USPATENTCITATION fwd
        ON p."id" = fwd."patent_id"
    JOIN PATENTSVIEW.PATENTSVIEW.APPLICATION app
        ON p."id" = app."patent_id"
    WHERE TRY_TO_DATE(fwd."date", 'YYYY-MM-DD') IS NOT NULL
      AND TRY_TO_DATE(fwd."date", 'YYYY-MM-DD') > app."date"
      AND TRY_TO_DATE(fwd."date", 'YYYY-MM-DD') <= DATEADD(MONTH, 1, app."date")
    GROUP BY p."id"
)
SELECT DISTINCT 
    p."id" AS "patent_id",
    p."title",
    app."date" AS "application_date",
    COALESCE(bwd."backward_citation_count", 0) AS "backward_citation_count",
    COALESCE(fwd."forward_citation_count", 0) AS "forward_citation_count",
    p."abstract"
FROM PATENTSVIEW.PATENTSVIEW.PATENT p
JOIN PATENTSVIEW.PATENTSVIEW.APPLICATION app
    ON p."id" = app."patent_id"
JOIN PATENTSVIEW.PATENTSVIEW.CPC_CURRENT cpc
    ON p."id" = cpc."patent_id"
LEFT JOIN backward_citations bwd
    ON p."id" = bwd."patent_id"
LEFT JOIN forward_citations fwd
    ON p."id" = fwd."patent_id"
WHERE (cpc."subsection_id" = 'C05' OR cpc."group_id" = 'A01G')
  AND (COALESCE(bwd."backward_citation_count", 0) > 0 
       OR COALESCE(fwd."forward_citation_count", 0) > 0)
ORDER BY app."date"