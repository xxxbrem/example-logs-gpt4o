SELECT "dma_name", 
       "dma_id", 
       "term", 
       "rank", 
       MAX("score") AS "highest_score", 
       "percent_gain", 
       "week"
FROM "GOOGLE_TRENDS"."GOOGLE_TRENDS"."TOP_RISING_TERMS"
WHERE "rank" = 1 
  AND "week" = (SELECT MAX("week") 
                FROM "GOOGLE_TRENDS"."GOOGLE_TRENDS"."TOP_RISING_TERMS"
                WHERE "week" <= DATEADD(YEAR, -1, (SELECT MAX("week") 
                                                  FROM "GOOGLE_TRENDS"."GOOGLE_TRENDS"."TOP_RISING_TERMS")))
GROUP BY "dma_name", "dma_id", "term", "rank", "percent_gain", "week"
ORDER BY "highest_score" DESC NULLS LAST
LIMIT 20;