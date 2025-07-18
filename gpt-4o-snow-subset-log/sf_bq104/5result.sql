SELECT 
    "term", 
    "dma_name", 
    "score", 
    "rank"
FROM 
    "GOOGLE_TRENDS"."GOOGLE_TRENDS"."TOP_RISING_TERMS"
WHERE 
    "week" BETWEEN DATEADD(MONTH, -1, DATEADD(YEAR, -1, (SELECT MAX("week") FROM "GOOGLE_TRENDS"."GOOGLE_TRENDS"."TOP_RISING_TERMS")))
               AND DATEADD(MONTH, 1, DATEADD(YEAR, -1, (SELECT MAX("week") FROM "GOOGLE_TRENDS"."GOOGLE_TRENDS"."TOP_RISING_TERMS")))
    AND "refresh_date" = (SELECT MAX("refresh_date") FROM "GOOGLE_TRENDS"."GOOGLE_TRENDS"."TOP_RISING_TERMS")
ORDER BY 
    "rank" ASC, 
    "score" DESC NULLS LAST
LIMIT 1;