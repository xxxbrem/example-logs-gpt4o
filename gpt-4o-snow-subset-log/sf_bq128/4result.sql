WITH backward_citations AS (
    SELECT 
        "patent_id", 
        COUNT("citation_id") AS "backward_citation_count"
    FROM PATENTSVIEW.PATENTSVIEW.USPATENTCITATION
    WHERE "date" < '2014-01-01'
    GROUP BY "patent_id"
),
forward_citations AS (
    SELECT 
        "citation_id" AS "patent_id",
        COUNT("patent_id") AS "forward_citation_count_within_5_years"
    FROM PATENTSVIEW.PATENTSVIEW.USPATENTCITATION
    WHERE "date" BETWEEN '2014-01-01' AND '2019-01-01'
    GROUP BY "citation_id"
)
SELECT 
    P."id" AS "patent_id",
    P."title",
    P."abstract",
    P."date" AS "publication_date",
    P."num_claims",
    COALESCE(BC."backward_citation_count", 0) AS "backward_citation_count",
    COALESCE(FC."forward_citation_count_within_5_years", 0) AS "forward_citation_count_within_5_years"
FROM PATENTSVIEW.PATENTSVIEW.PATENT P
LEFT JOIN backward_citations BC ON P."id" = BC."patent_id"
LEFT JOIN forward_citations FC ON P."id" = FC."patent_id"
WHERE P."country" = 'US' 
  AND P."date" BETWEEN '2014-01-01' AND '2014-02-01'
LIMIT 20;