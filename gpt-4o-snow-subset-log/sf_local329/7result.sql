SELECT COUNT(DISTINCT "session") AS "unique_sessions"
FROM (
    SELECT "session", "path", 
           LAG("path") OVER (PARTITION BY "session" ORDER BY "stamp") AS "previous_path"
    FROM "LOG"."LOG"."FORM_LOG"
    WHERE "path" IN ('/regist/input', '/regist/confirm')
    QUALIFY LAG("path") OVER (PARTITION BY "session" ORDER BY "stamp") = '/regist/input'
    AND "path" = '/regist/confirm'
) subquery;