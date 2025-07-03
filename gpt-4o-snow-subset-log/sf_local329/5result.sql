WITH RankedPaths AS (
    SELECT 
        "session", 
        "path", 
        "stamp", 
        ROW_NUMBER() OVER (PARTITION BY "session" ORDER BY "stamp") AS rank
    FROM LOG.LOG.FORM_LOG
    WHERE "path" IN ('/regist/input', '/regist/confirm')
)
SELECT COUNT(DISTINCT rp1."session") AS "unique_sessions"
FROM RankedPaths rp1
JOIN RankedPaths rp2 
  ON rp1."session" = rp2."session" 
  AND rp1.rank + 1 = rp2.rank
WHERE rp1."path" = '/regist/input' 
  AND rp2."path" = '/regist/confirm';