WITH CPC_FILTERED AS (
    SELECT DISTINCT 
        c."patent_id"
    FROM PATENTSVIEW.PATENTSVIEW.CPC_CURRENT c
    WHERE c."subsection_id" = 'C05' OR c."group_id" = 'A01G'
),
PATENT_DETAILS AS (
    SELECT 
        p."id" AS "patent_id", 
        p."title", 
        p."abstract"
    FROM PATENTSVIEW.PATENTSVIEW.PATENT p
    WHERE p."country" = 'US'
),
APPLICATION_DETAILS AS (
    SELECT 
        a."patent_id", 
        a."date" AS "application_date"
    FROM PATENTSVIEW.PATENTSVIEW.APPLICATION a
    WHERE TRY_TO_DATE(a."date", 'YYYY-MM-DD') IS NOT NULL -- Ensure valid date formats
),
BACKWARD_CITATIONS AS (
    SELECT 
        uc."patent_id", 
        COUNT(uc."citation_id") AS "backward_citation_count"
    FROM PATENTSVIEW.PATENTSVIEW.USPATENTCITATION uc
    INNER JOIN APPLICATION_DETAILS ad
        ON uc."citation_id" = ad."patent_id" 
        AND uc."date" <= ad."application_date"
        AND uc."date" >= DATEADD(month, -1, ad."application_date")
        AND TRY_TO_DATE(uc."date", 'YYYY-MM-DD') IS NOT NULL -- Validate citation date format
    GROUP BY uc."patent_id"
),
FORWARD_CITATIONS AS (
    SELECT 
        uc."citation_id" AS "patent_id", 
        COUNT(uc."patent_id") AS "forward_citation_count"
    FROM PATENTSVIEW.PATENTSVIEW.USPATENTCITATION uc
    INNER JOIN APPLICATION_DETAILS ad
        ON uc."patent_id" = ad."patent_id" 
        AND uc."date" >= ad."application_date"
        AND uc."date" <= DATEADD(month, 1, ad."application_date")
        AND TRY_TO_DATE(uc."date", 'YYYY-MM-DD') IS NOT NULL -- Validate citation date format
    GROUP BY uc."citation_id"
)
SELECT 
    pd."patent_id", 
    pd."title", 
    ad."application_date", 
    COALESCE(bc."backward_citation_count", 0) AS "backward_citation_count", 
    COALESCE(fc."forward_citation_count", 0) AS "forward_citation_count", 
    pd."abstract"
FROM PATENT_DETAILS pd
INNER JOIN CPC_FILTERED cf
    ON pd."patent_id" = cf."patent_id"
INNER JOIN APPLICATION_DETAILS ad
    ON pd."patent_id" = ad."patent_id"
LEFT JOIN BACKWARD_CITATIONS bc
    ON pd."patent_id" = bc."patent_id"
LEFT JOIN FORWARD_CITATIONS fc
    ON pd."patent_id" = fc."patent_id"
WHERE COALESCE(bc."backward_citation_count", 0) > 0 OR COALESCE(fc."forward_citation_count", 0) > 0
ORDER BY ad."application_date"