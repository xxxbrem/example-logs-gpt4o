SELECT 
    w1."name" AS "winner_name", 
    w2."name" AS "loser_name"
FROM 
    "WWE"."WWE"."MATCHES" AS m
JOIN 
    "WWE"."WWE"."WRESTLERS" AS w1 
    ON m."winner_id" = w1."id"
JOIN 
    "WWE"."WWE"."WRESTLERS" AS w2 
    ON m."loser_id" = w2."id"
WHERE 
    m."title_id" IN (
        SELECT "id" 
        FROM "WWE"."WWE"."BELTS"
        WHERE "name" ILIKE '%NXT%'
    )
    AND m."title_change" = 0
    AND m."duration" = (
        SELECT MIN("duration") 
        FROM "WWE"."WWE"."MATCHES"
        WHERE "title_id" IN (
            SELECT "id" 
            FROM "WWE"."WWE"."BELTS"
            WHERE "name" ILIKE '%NXT%'
        )
        AND "title_change" = 0
    )
LIMIT 1;