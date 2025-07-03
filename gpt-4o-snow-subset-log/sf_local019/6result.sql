SELECT 
    w1."name" AS "winner_name", 
    w2."name" AS "loser_name"
FROM "WWE"."WWE"."MATCHES" AS m
JOIN "WWE"."WWE"."BELTS" AS b ON m."title_id" = b."id"
JOIN "WWE"."WWE"."WRESTLERS" AS w1 ON m."winner_id" = w1."id"::TEXT
JOIN "WWE"."WWE"."WRESTLERS" AS w2 ON m."loser_id" = w2."id"
WHERE b."name" ILIKE '%NXT%'
  AND m."title_change" = 0
  AND m."duration" IS NOT NULL
ORDER BY LENGTH(m."duration"), m."duration" ASC
LIMIT 1;