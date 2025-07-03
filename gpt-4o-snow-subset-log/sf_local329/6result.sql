SELECT COUNT(DISTINCT "session") AS "unique_sessions_count" 
FROM (
    SELECT DISTINCT f1."session"
    FROM "LOG"."LOG"."FORM_LOG" f1
    JOIN "LOG"."LOG"."FORM_LOG" f2 
        ON f1."session" = f2."session" AND f1."stamp" < f2."stamp"
    WHERE f1."path" = '/regist/input' AND f2."path" = '/regist/confirm'
) subquery;