SELECT COUNT(DISTINCT f1."session") AS "unique_sessions"
FROM "LOG"."LOG"."FORM_LOG" f1
JOIN "LOG"."LOG"."FORM_LOG" f2
  ON f1."session" = f2."session"
WHERE f1."path" ILIKE '%/regist/input%'
  AND f2."path" ILIKE '%/regist/confirm%'
  AND f1."stamp" < f2."stamp";