SELECT "dma_name", 
       "dma_id", 
       "term", 
       "rank", 
       "score", 
       "percent_gain", 
       "week"
FROM "GOOGLE_TRENDS"."GOOGLE_TRENDS"."TOP_RISING_TERMS"
WHERE "refresh_date" = (SELECT MAX("refresh_date") 
                        FROM "GOOGLE_TRENDS"."GOOGLE_TRENDS"."TOP_RISING_TERMS")
  AND "week" = (SELECT MAX("week")
                FROM "GOOGLE_TRENDS"."GOOGLE_TRENDS"."TOP_RISING_TERMS"
                WHERE "refresh_date" = (SELECT MAX("refresh_date") 
                                        FROM "GOOGLE_TRENDS"."GOOGLE_TRENDS"."TOP_RISING_TERMS")) 
                - INTERVAL '52 WEEKS'
ORDER BY "rank" ASC
LIMIT 1;