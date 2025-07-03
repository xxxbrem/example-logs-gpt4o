WITH CPC_FILTERED_PATENTS AS (
    SELECT DISTINCT 
        p."id" AS "patent_id", 
        p."title", 
        TRY_TO_DATE(a."date", 'YYYY-MM-DD') AS "application_date", 
        p."abstract", 
        c."subsection_id",
        c."group_id"
    FROM PATENTSVIEW.PATENTSVIEW.PATENT p
    JOIN PATENTSVIEW.PATENTSVIEW.APPLICATION a
        ON p."id" = a."patent_id"
    JOIN PATENTSVIEW.PATENTSVIEW.CPC_CURRENT c
        ON p."id" = c."patent_id"
    WHERE p."country" = 'US'
      AND (c."subsection_id" = 'C05' OR c."group_id" = 'A01G')
      AND TRY_TO_DATE(a."date", 'YYYY-MM-DD') IS NOT NULL
),
BACKWARD_CITATIONS AS (
    SELECT 
        cited."patent_id", 
        COUNT(*) AS "backward_citation_count"
    FROM CPC_FILTERED_PATENTS target
    JOIN PATENTSVIEW.PATENTSVIEW.USPATENTCITATION cited
        ON cited."citation_id" = target."patent_id"
    WHERE DATEADD('day', -30, target."application_date") <= TRY_TO_DATE(cited."date", 'YYYY-MM-DD') 
      AND TRY_TO_DATE(cited."date", 'YYYY-MM-DD') < target."application_date"
    GROUP BY cited."patent_id"
),
FORWARD_CITATIONS AS (
    SELECT 
        target."patent_id", 
        COUNT(*) AS "forward_citation_count"
    FROM CPC_FILTERED_PATENTS target
    JOIN PATENTSVIEW.PATENTSVIEW.USPATENTCITATION forward
        ON forward."patent_id" = target."patent_id"
    WHERE target."application_date" <= TRY_TO_DATE(forward."date", 'YYYY-MM-DD')
      AND TRY_TO_DATE(forward."date", 'YYYY-MM-DD') < DATEADD('day', 30, target."application_date")
    GROUP BY target."patent_id"
)
SELECT 
    fpat."patent_id", 
    fpat."title", 
    fpat."application_date", 
    COALESCE(bc."backward_citation_count", 0) AS "backward_citation_count",
    COALESCE(fc."forward_citation_count", 0) AS "forward_citation_count", 
    fpat."abstract"
FROM CPC_FILTERED_PATENTS fpat
LEFT JOIN BACKWARD_CITATIONS bc
    ON fpat."patent_id" = bc."patent_id"
LEFT JOIN FORWARD_CITATIONS fc
    ON fpat."patent_id" = fc."patent_id"
WHERE COALESCE(bc."backward_citation_count", 0) > 0
   OR COALESCE(fc."forward_citation_count", 0) > 0
ORDER BY fpat."application_date";