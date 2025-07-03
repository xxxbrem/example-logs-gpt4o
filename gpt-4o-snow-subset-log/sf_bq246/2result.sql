WITH BackwardCitationCounts AS (
    -- Count backward citations within 1 year before application date
    SELECT 
        f."patent_id",
        COUNT(f."number") AS "backward_citations"
    FROM PATENTSVIEW.PATENTSVIEW.FOREIGNCITATION f
    JOIN PATENTSVIEW.PATENTSVIEW.APPLICATION a
      ON f."patent_id" = a."patent_id"
    WHERE TRY_TO_DATE(f."date") IS NOT NULL
      AND TRY_TO_DATE(a."date") IS NOT NULL
      AND TRY_TO_DATE(f."date") >= DATEADD(year, -1, TRY_TO_DATE(a."date"))
      AND TRY_TO_DATE(f."date") < TRY_TO_DATE(a."date")
    GROUP BY f."patent_id"
),
MostBackwardCitedPatent AS (
    -- Get the patent with the most backward citations
    SELECT 
        "patent_id"
    FROM BackwardCitationCounts
    ORDER BY "backward_citations" DESC NULLS LAST
    LIMIT 1
),
ForwardCitationCounts AS (
    -- Count forward citations within 1 year after application date
    SELECT 
        c."patent_id",
        COUNT(c."citation_id") AS "forward_citations"
    FROM PATENTSVIEW.PATENTSVIEW.USPATENTCITATION c
    JOIN PATENTSVIEW.PATENTSVIEW.APPLICATION a
      ON c."patent_id" = a."patent_id"
    WHERE TRY_TO_DATE(c."date") IS NOT NULL
      AND TRY_TO_DATE(a."date") IS NOT NULL
      AND TRY_TO_DATE(c."date") >= TRY_TO_DATE(a."date")
      AND TRY_TO_DATE(c."date") < DATEADD(year, 1, TRY_TO_DATE(a."date"))
    GROUP BY c."patent_id"
)
-- Combine and return the final output
SELECT 
    mbp."patent_id",
    bcc."backward_citations",
    fcc."forward_citations"
FROM MostBackwardCitedPatent mbp
LEFT JOIN BackwardCitationCounts bcc
  ON mbp."patent_id" = bcc."patent_id"
LEFT JOIN ForwardCitationCounts fcc
  ON mbp."patent_id" = fcc."patent_id";