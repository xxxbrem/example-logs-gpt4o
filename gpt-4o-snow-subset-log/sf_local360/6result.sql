WITH first_event_time AS (
    SELECT 
        "session", 
        MIN("stamp") AS first_event_time
    FROM LOG.LOG.ACTIVITY_LOG 
    WHERE "path" IN ('/detail/', '/complete/')
    GROUP BY "session"
),
pre_event_counts AS (
    SELECT 
        a."session", 
        COUNT(*) AS pre_event_count
    FROM LOG.LOG.ACTIVITY_LOG a
    JOIN first_event_time f 
        ON a."session" = f."session"
    WHERE a."stamp" < f.first_event_time 
        AND a."search_type" != ''
    GROUP BY a."session"
),
min_sessions AS (
    SELECT 
        p."session"
    FROM pre_event_counts p
    WHERE p.pre_event_count = (
        SELECT MIN(pre_event_count) 
        FROM pre_event_counts
    )
)
SELECT 
    a."session", 
    a."path", 
    a."search_type"
FROM LOG.LOG.ACTIVITY_LOG a
JOIN min_sessions m 
    ON a."session" = m."session"
WHERE a."search_type" != ''
ORDER BY a."session", a."stamp";