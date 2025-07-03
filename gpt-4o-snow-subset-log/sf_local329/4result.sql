WITH ranked_log AS (
    SELECT "session", "path", "stamp",
           ROW_NUMBER() OVER(PARTITION BY "session" ORDER BY "stamp") AS "row_num"
    FROM LOG.LOG.FORM_LOG
    WHERE "path" IN ('/regist/input', '/regist/confirm')
)
SELECT COUNT(DISTINCT r1."session") AS "unique_sessions_count"
FROM ranked_log r1
JOIN ranked_log r2
  ON r1."session" = r2."session"
WHERE r1."path" = '/regist/input'
  AND r2."path" = '/regist/confirm'
  AND r1."row_num" < r2."row_num";