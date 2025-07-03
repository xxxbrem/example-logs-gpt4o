WITH PreEventCounts AS (
    SELECT 
        t1."session", 
        COUNT(*) AS "pre_event_count"
    FROM 
        LOG.LOG.ACTIVITY_LOG t1
    WHERE 
        t1."search_type" IS NOT NULL 
        AND t1."search_type" != ''
        AND NOT EXISTS (
            SELECT 1 
            FROM LOG.LOG.ACTIVITY_LOG t2
            WHERE 
                t1."session" = t2."session" 
                AND t2."path" IN ('/detail/', '/complete/')
                AND t2."stamp" <= t1."stamp"
        )
    GROUP BY 
        t1."session"
)
SELECT 
    t1."session", 
    t1."path", 
    t1."search_type" 
FROM 
    LOG.LOG.ACTIVITY_LOG t1
WHERE 
    t1."session" IN (
        SELECT "session" 
        FROM PreEventCounts 
        WHERE "pre_event_count" = (
            SELECT MIN("pre_event_count") 
            FROM PreEventCounts
        )
    )
ORDER BY 
    t1."session", 
    t1."stamp"
LIMIT 20;