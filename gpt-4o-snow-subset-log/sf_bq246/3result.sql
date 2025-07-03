SELECT b."patent_id", 
       COUNT(DISTINCT b."uuid") AS "backward_count", 
       COUNT(DISTINCT f."uuid") AS "forward_count_within_3_years",
       TRY_TO_DATE(p."date") AS "application_date"
FROM PATENTSVIEW.PATENTSVIEW.FOREIGNCITATION b
JOIN PATENTSVIEW.PATENTSVIEW.PATENT p 
    ON b."patent_id" = p."id"
JOIN PATENTSVIEW.PATENTSVIEW.CPC_CURRENT c 
    ON c."patent_id" = b."patent_id"
LEFT JOIN PATENTSVIEW.PATENTSVIEW.USPATENTCITATION f
    ON f."citation_id" = p."id" 
    AND TRY_TO_DATE(f."date") IS NOT NULL 
    AND TRY_TO_DATE(f."date") >= TRY_TO_DATE(p."date") 
    AND TRY_TO_DATE(f."date") <= DATEADD(year, 3, TRY_TO_DATE(p."date"))
WHERE p."country" = 'US'
  AND c."category" = 'inventional'
  AND TRY_TO_DATE(p."date") IS NOT NULL
  AND TRY_TO_DATE(b."date") IS NOT NULL
  AND TRY_TO_DATE(b."date") >= DATEADD(year, -1, TRY_TO_DATE(p."date"))
  AND TRY_TO_DATE(b."date") < TRY_TO_DATE(p."date")
GROUP BY b."patent_id", TRY_TO_DATE(p."date")
ORDER BY "backward_count" DESC NULLS LAST
LIMIT 1;