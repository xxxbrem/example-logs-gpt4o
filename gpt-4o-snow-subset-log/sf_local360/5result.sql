WITH first_events AS (
    SELECT 
        "session", 
        MIN("stamp") AS first_event_time
    FROM 
        LOG.LOG.ACTIVITY_LOG
    WHERE 
        "path" = '/detail' OR "path" ILIKE '%complete%'
    GROUP BY 
        "session"
),
pre_event_counts AS (
    SELECT 
        a."session", 
        COUNT(*) AS pre_event_count
    FROM 
        LOG.LOG.ACTIVITY_LOG a
    JOIN 
        first_events b 
    ON 
        a."session" = b."session" 
        AND a."stamp" < b.first_event_time
    WHERE 
        a."search_type" IS NOT NULL 
        AND a."search_type" != ''
    GROUP BY 
        a."session"
)
SELECT DISTINCT
    a."session", 
    a."path", 
    a."search_type"
FROM 
    LOG.LOG.ACTIVITY_LOG a
JOIN 
    pre_event_counts c 
ON 
    a."session" = c."session"
WHERE 
    c.pre_event_count = (
        SELECT MIN(pre_event_count) 
        FROM pre_event_counts
    )
ORDER BY 
    a."session", 
    a."path", 
    a."search_type";