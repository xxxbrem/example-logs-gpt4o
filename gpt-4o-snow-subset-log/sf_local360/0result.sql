WITH pre_click_counts AS (
  SELECT 
    "session", 
    COUNT(*) AS "pre_conversion_events"
  FROM LOG.LOG.ACTIVITY_LOG
  WHERE "search_type" <> '' 
    AND "path" NOT ILIKE '%/detail%' 
    AND "path" NOT ILIKE '%/complete%'
  GROUP BY "session"
), min_counts AS (
  SELECT MIN("pre_conversion_events") AS "min_count"
  FROM pre_click_counts
), sessions_with_min_counts AS (
  SELECT "session"
  FROM pre_click_counts
  WHERE "pre_conversion_events" = (SELECT "min_count" FROM min_counts)
)
SELECT 
  al."session", 
  al."path", 
  al."search_type"
FROM LOG.LOG.ACTIVITY_LOG al
JOIN sessions_with_min_counts min_sessions 
  ON al."session" = min_sessions."session"
WHERE al."search_type" <> '' 
  AND al."path" NOT ILIKE '%/detail%' 
  AND al."path" NOT ILIKE '%/complete%'
ORDER BY al."session", al."stamp";