WITH PreClickEvents AS (
  SELECT 
    e1."session", 
    COUNT(*) AS "pre_click_events"
  FROM "LOG"."LOG"."ACTIVITY_LOG" e1
  WHERE e1."search_type" <> ''
    AND e1."stamp" < (
      SELECT MIN(e2."stamp") 
      FROM "LOG"."LOG"."ACTIVITY_LOG" e2
      WHERE e2."session" = e1."session" 
        AND e2."path" IN ('/detail/', '/complete/')
    )
  GROUP BY e1."session"
),
MinEvents AS (
  SELECT 
    MIN("pre_click_events") AS "min_events"
  FROM PreClickEvents
)
SELECT 
  p."session", 
  a."path", 
  a."search_type"
FROM "LOG"."LOG"."ACTIVITY_LOG" a
JOIN PreClickEvents p 
  ON a."session" = p."session"
JOIN MinEvents m 
  ON p."pre_click_events" = m."min_events"
WHERE a."search_type" <> ''
ORDER BY p."session", a."stamp" ASC;