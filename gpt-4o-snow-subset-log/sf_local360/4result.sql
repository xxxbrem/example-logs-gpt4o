WITH PreClickEvents AS (
    SELECT 
        "session", 
        COUNT(*) AS "pre_click_events"
    FROM LOG.LOG.ACTIVITY_LOG
    WHERE 
        "search_type" != '' 
        AND "path" NOT ILIKE '%/detail%' 
        AND "path" NOT ILIKE '%/complete%'
    GROUP BY "session"
),
MinPreClickEvents AS (
    SELECT 
        MIN("pre_click_events") AS "min_events"
    FROM PreClickEvents
)
SELECT 
    a."session", 
    a."path", 
    a."search_type"
FROM LOG.LOG.ACTIVITY_LOG a
JOIN PreClickEvents b ON a."session" = b."session"
CROSS JOIN MinPreClickEvents c
WHERE b."pre_click_events" = c."min_events"
ORDER BY a."session", a."stamp";