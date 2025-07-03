WITH BackwardCitations AS (
  SELECT a."patent_id", COUNT(u."citation_id") AS "backward_citation_count", a."date" AS "application_date"
  FROM PATENTSVIEW.PATENTSVIEW.APPLICATION a
  JOIN PATENTSVIEW.PATENTSVIEW.USPATENTCITATION u
    ON a."patent_id" = u."patent_id"
  WHERE a."country" = 'US'
    AND u."category" = 'cited by applicant'
    AND TRY_CAST(a."date" AS DATE) IS NOT NULL  -- Ensure valid "a.date" timestamps
    AND TRY_CAST(u."date" AS DATE) IS NOT NULL  -- Ensure valid "u.date" timestamps
    AND u."date" BETWEEN DATEADD(YEAR, -1, TRY_CAST(a."date" AS DATE)) AND TRY_CAST(a."date" AS DATE)
  GROUP BY a."patent_id", a."date"
  ORDER BY "backward_citation_count" DESC NULLS LAST
  LIMIT 1  -- Get the patent with the most backward citations
),
ForwardCitations AS (
  SELECT a."patent_id", COUNT(u."patent_id") AS "forward_citation_count"
  FROM BackwardCitations b
  JOIN PATENTSVIEW.PATENTSVIEW.APPLICATION a
    ON b."patent_id" = a."patent_id"
  JOIN PATENTSVIEW.PATENTSVIEW.USPATENTCITATION u
    ON a."patent_id" = u."citation_id"
  WHERE TRY_CAST(a."date" AS DATE) IS NOT NULL  -- Ensure valid "a.date" timestamps
    AND TRY_CAST(u."date" AS DATE) IS NOT NULL  -- Ensure valid "u.date" timestamps
    AND u."date" BETWEEN TRY_CAST(a."date" AS DATE) AND DATEADD(YEAR, 1, TRY_CAST(a."date" AS DATE))
  GROUP BY a."patent_id"
)
SELECT b."patent_id", b."backward_citation_count", f."forward_citation_count"
FROM BackwardCitations b
LEFT JOIN ForwardCitations f ON b."patent_id" = f."patent_id"
LIMIT 1;