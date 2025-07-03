WITH PreClickEvents AS (
    -- Count events with non-empty search_type before '/detail' or '/complete' for each session
    SELECT 
        a."session", 
        COUNT(*) AS "pre_events_count"
    FROM LOG.LOG.ACTIVITY_LOG AS a
    WHERE a."search_type" != '' 
      AND NOT EXISTS (
          SELECT 1 
          FROM LOG.LOG.ACTIVITY_LOG AS b 
          WHERE a."session" = b."session" 
            AND b."path" IN ('/detail', '/complete') 
            AND a."stamp" >= b."stamp"
      )
    GROUP BY a."session"
),
MinSessions AS (
    -- Find sessions with the minimum count of pre-click/pre-conversion events
    SELECT "session"
    FROM PreClickEvents
    WHERE "pre_events_count" = (
        SELECT MIN("pre_events_count") 
        FROM PreClickEvents
    )
)
-- Retrieve paths and search types for the sessions with the minimum count
SELECT DISTINCT a."session", a."path", a."search_type"
FROM LOG.LOG.ACTIVITY_LOG AS a
JOIN MinSessions AS m ON a."session" = m."session"
WHERE a."search_type" != ''
ORDER BY a."session", a."path";