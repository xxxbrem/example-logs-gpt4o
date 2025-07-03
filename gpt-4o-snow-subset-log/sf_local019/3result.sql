SELECT wr1."name" AS "winner_name", wr2."name" AS "loser_name"
FROM "WWE"."WWE"."MATCHES" m
JOIN "WWE"."WWE"."WRESTLERS" wr1 ON m."winner_id" = wr1."id"
JOIN "WWE"."WWE"."WRESTLERS" wr2 ON m."loser_id" = wr2."id"
WHERE m."title_id" IN (
    SELECT "id"
    FROM "WWE"."WWE"."BELTS"
    WHERE "name" LIKE '%NXT%'
) 
AND m."title_change" = 0
ORDER BY m."duration" ASC 
LIMIT 1;