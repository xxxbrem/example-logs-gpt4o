WITH PreClickEvents AS (
  SELECT 
    "session", 
    COUNT(*) AS "pre_click_event_count" 
  FROM 
    "LOG"."LOG"."ACTIVITY_LOG" a
  WHERE 
    "search_type" IS NOT NULL 
    AND "search_type" != '' 
    AND "stamp" < (
      SELECT MIN("stamp") 
      FROM "LOG"."LOG"."ACTIVITY_LOG" b 
      WHERE 
        b."session" = a."session" 
        AND b."path" IN ('/detail', '/complete')
    )
  GROUP BY 
    "session"
),
MinSessions AS (
  SELECT 
    "session" 
  FROM 
    PreClickEvents 
  WHERE 
    "pre_click_event_count" = (
      SELECT MIN("pre_click_event_count") 
      FROM PreClickEvents
    )
)
SELECT 
  a."session", 
  a."path", 
  a."search_type"
FROM 
  "LOG"."LOG"."ACTIVITY_LOG" a
JOIN 
  MinSessions b
  ON a."session" = b."session" 
WHERE 
  a."search_type" IS NOT NULL 
  AND a."search_type" != ''
ORDER BY 
  a."session", 
  a."stamp";