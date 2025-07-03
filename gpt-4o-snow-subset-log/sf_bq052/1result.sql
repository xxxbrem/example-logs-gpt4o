WITH FilteredPatents AS (
    SELECT DISTINCT p."id" AS "patent_id",
           p."title",
           a."date" AS "application_date",
           p."abstract"
    FROM "PATENTSVIEW"."PATENTSVIEW"."PATENT" p
    JOIN "PATENTSVIEW"."PATENTSVIEW"."CPC_CURRENT" cpc ON p."id" = cpc."patent_id"
    JOIN "PATENTSVIEW"."PATENTSVIEW"."APPLICATION" a ON p."id" = a."patent_id"
    WHERE (cpc."subsection_id" = 'C05' OR cpc."group_id" = 'A01G')
      AND p."country" = 'US'
      AND TRY_TO_DATE(a."date", 'YYYY-MM-DD') IS NOT NULL
),
BackwardCitations AS (
    SELECT bc."citation_id" AS "cited_patent_id",
           bc."patent_id" AS "current_patent_id",
           COUNT(*) AS "backward_count"
    FROM "PATENTSVIEW"."PATENTSVIEW"."USPATENTCITATION" bc
    JOIN FilteredPatents fp ON bc."patent_id" = fp."patent_id"
    WHERE TRY_TO_DATE(bc."date", 'YYYY-MM-DD') <= TRY_TO_DATE(fp."application_date", 'YYYY-MM-DD') 
      AND TRY_TO_DATE(bc."date", 'YYYY-MM-DD') > DATEADD(MONTH, -1, TRY_TO_DATE(fp."application_date", 'YYYY-MM-DD'))
    GROUP BY bc."patent_id", bc."citation_id"
),
ForwardCitations AS (
    SELECT fc."patent_id" AS "cited_patent_id",
           fc."citation_id" AS "current_patent_id",
           COUNT(*) AS "forward_count"
    FROM "PATENTSVIEW"."PATENTSVIEW"."USPATENTCITATION" fc
    JOIN FilteredPatents fp ON fc."citation_id" = fp."patent_id"
    WHERE TRY_TO_DATE(fc."date", 'YYYY-MM-DD') >= TRY_TO_DATE(fp."application_date", 'YYYY-MM-DD') 
      AND TRY_TO_DATE(fc."date", 'YYYY-MM-DD') < DATEADD(MONTH, 1, TRY_TO_DATE(fp."application_date", 'YYYY-MM-DD'))
    GROUP BY fc."patent_id", fc."citation_id"
),
CombinedCitations AS (
    SELECT fp."patent_id",
           fp."title",
           fp."application_date",
           fp."abstract",
           COALESCE(bw."backward_count", 0) AS "backward_count",
           COALESCE(fw."forward_count", 0) AS "forward_count"
    FROM FilteredPatents fp
    LEFT JOIN (
        SELECT "current_patent_id", SUM("backward_count") AS "backward_count"
        FROM BackwardCitations
        GROUP BY "current_patent_id"
    ) bw ON fp."patent_id" = bw."current_patent_id"
    LEFT JOIN (
        SELECT "current_patent_id", SUM("forward_count") AS "forward_count"
        FROM ForwardCitations
        GROUP BY "current_patent_id"
    ) fw ON fp."patent_id" = fw."current_patent_id"
)
SELECT "patent_id",
       "title",
       "application_date",
       "backward_count",
       "forward_count",
       "abstract"
FROM CombinedCitations
WHERE "backward_count" > 0 OR "forward_count" > 0
ORDER BY TRY_TO_DATE("application_date", 'YYYY-MM-DD') ASC;