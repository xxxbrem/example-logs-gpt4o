WITH backward_citations AS (
    SELECT 
        P."id" AS patent_id, 
        COUNT(U."citation_id") AS backward_citation_count
    FROM PATENTSVIEW.PATENTSVIEW.PATENT AS P
    LEFT JOIN PATENTSVIEW.PATENTSVIEW.USPATENTCITATION AS U
        ON P."id" = U."patent_id" AND U."date" < P."date"
    WHERE P."country" = 'US' 
      AND P."date" >= '2014-01-01' 
      AND P."date" <= '2014-02-01'
    GROUP BY P."id"
),
forward_citations AS (
    SELECT 
        P."id" AS patent_id, 
        COUNT(U."patent_id") AS forward_citation_count
    FROM PATENTSVIEW.PATENTSVIEW.PATENT AS P
    LEFT JOIN PATENTSVIEW.PATENTSVIEW.USPATENTCITATION AS U
        ON P."id" = U."citation_id" AND U."date" <= DATEADD(year, 5, P."date")
    WHERE P."country" = 'US' 
      AND P."date" >= '2014-01-01' 
      AND P."date" <= '2014-02-01'
    GROUP BY P."id"
)
SELECT 
    P."title",
    P."abstract",
    P."date" AS publication_date,
    COALESCE(B.backward_citation_count, 0) AS backward_citation_count,
    COALESCE(F.forward_citation_count, 0) AS forward_citation_count
FROM PATENTSVIEW.PATENTSVIEW.PATENT AS P
LEFT JOIN backward_citations AS B
    ON P."id" = B.patent_id
LEFT JOIN forward_citations AS F
    ON P."id" = F.patent_id
WHERE P."country" = 'US' 
  AND P."date" >= '2014-01-01' 
  AND P."date" <= '2014-02-01'
LIMIT 20;