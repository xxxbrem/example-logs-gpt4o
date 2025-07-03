SELECT COUNT(DISTINCT t1."session") AS "unique_sessions" 
FROM "LOG"."LOG"."FORM_LOG" t1 
JOIN "LOG"."LOG"."FORM_LOG" t2 
ON t1."session" = t2."session" 
WHERE t1."path" = '/regist/input' 
  AND t2."path" = '/regist/confirm' 
  AND t1."stamp" < t2."stamp";