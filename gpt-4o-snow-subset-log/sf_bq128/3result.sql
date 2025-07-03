WITH BackwardCitation AS (
    SELECT "patent_id", COUNT("citation_id") AS "backward_citation_count"
    FROM PATENTSVIEW.PATENTSVIEW.USPATENTCITATION
    WHERE "date" < '2014-01-01'
    GROUP BY "patent_id"
),
ForwardCitation AS (
    SELECT "citation_id", COUNT("patent_id") AS "forward_citation_count"
    FROM PATENTSVIEW.PATENTSVIEW.USPATENTCITATION
    WHERE "date" >= '2014-01-01' AND "date" < '2019-01-01'
    GROUP BY "citation_id"
)
SELECT p."id", 
       p."title", 
       p."abstract", 
       p."date" AS "publication_date", 
       COALESCE(b."backward_citation_count", 0) AS "backward_citation_count", 
       COALESCE(f."forward_citation_count", 0) AS "forward_citation_count"
FROM PATENTSVIEW.PATENTSVIEW.PATENT p
LEFT JOIN BackwardCitation b ON p."id" = b."patent_id"
LEFT JOIN ForwardCitation f ON p."id" = f."citation_id"
WHERE p."date" >= '2014-01-01' AND p."date" <= '2014-02-01'
LIMIT 20;