SELECT 
    w1."name" AS "winner_name", 
    w2."name" AS "loser_name"
FROM "WWE"."WWE"."MATCHES" m
JOIN "WWE"."WWE"."WRESTLERS" w1 ON m."winner_id" = w1."id"
JOIN "WWE"."WWE"."WRESTLERS" w2 ON m."loser_id" = w2."id"
JOIN "WWE"."WWE"."BELTS" b ON m."title_id" = b."id"
WHERE b."name" ILIKE '%NXT%' 
  AND m."title_change" = 0
ORDER BY m."duration" ASC NULLS LAST
LIMIT 1;