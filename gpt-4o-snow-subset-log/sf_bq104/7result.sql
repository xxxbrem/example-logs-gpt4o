SELECT "dma_name", "dma_id", "term", "score", "rank", "percent_gain", "week", "refresh_date"
FROM "GOOGLE_TRENDS"."GOOGLE_TRENDS"."TOP_RISING_TERMS"
WHERE "week" = (SELECT MAX("week")
                FROM "GOOGLE_TRENDS"."GOOGLE_TRENDS"."TOP_RISING_TERMS"
                WHERE "week" <= (SELECT DATEADD(YEAR, -1, MAX("week"))
                                 FROM "GOOGLE_TRENDS"."GOOGLE_TRENDS"."TOP_RISING_TERMS"
                                 WHERE "refresh_date" = (SELECT MAX("refresh_date") 
                                                         FROM "GOOGLE_TRENDS"."GOOGLE_TRENDS"."TOP_RISING_TERMS")))
ORDER BY "rank" ASC
LIMIT 1;