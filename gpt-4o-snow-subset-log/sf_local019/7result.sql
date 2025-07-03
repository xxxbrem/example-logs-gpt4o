SELECT 
  (SELECT "name" 
   FROM "WWE"."WWE"."WRESTLERS" 
   WHERE "id" = (SELECT "winner_id"
                 FROM "WWE"."WWE"."MATCHES"
                 WHERE "title_id" = (SELECT "id" FROM "WWE"."WWE"."BELTS" WHERE "name" ILIKE '%NXT%' LIMIT 1)
                   AND "title_change" = 0
                 ORDER BY "duration" ASC NULLS LAST
                 LIMIT 1)) AS "Winner",
  (SELECT "name" 
   FROM "WWE"."WWE"."WRESTLERS"
   WHERE "id" = (SELECT "loser_id"
                 FROM "WWE"."WWE"."MATCHES"
                 WHERE "title_id" = (SELECT "id" FROM "WWE"."WWE"."BELTS" WHERE "name" ILIKE '%NXT%' LIMIT 1)
                   AND "title_change" = 0
                 ORDER BY "duration" ASC NULLS LAST
                 LIMIT 1)) AS "Loser";