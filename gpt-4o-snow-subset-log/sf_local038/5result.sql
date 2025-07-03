SELECT a."first_name", a."last_name"
FROM (
  SELECT fa."actor_id", COUNT(*) AS film_count
  FROM "PAGILA"."PAGILA"."FILM_ACTOR" fa
  JOIN "PAGILA"."PAGILA"."FILM_CATEGORY" fc
    ON fa."film_id" = fc."film_id"
  JOIN "PAGILA"."PAGILA"."FILM" f
    ON fc."film_id" = f."film_id"
  WHERE fc."category_id" = 8 -- Assuming 8 is the category_id for 'Children'
    AND f."language_id" = 1 
    AND f."rating" IN ('G', 'PG') 
    AND f."length" <= 120 
    AND f."release_year" BETWEEN '2000' AND '2010'
  GROUP BY fa."actor_id"
  ORDER BY film_count DESC NULLS LAST
  LIMIT 1
) most_frequent_actor
JOIN "PAGILA"."PAGILA"."ACTOR" a
  ON most_frequent_actor."actor_id" = a."actor_id";