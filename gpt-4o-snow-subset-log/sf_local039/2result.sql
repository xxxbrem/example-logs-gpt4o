SELECT "CATEGORY"."name" AS "category_name", SUM("FILM"."length") AS "total_rental_hours"
FROM "PAGILA"."PAGILA"."FILM" AS "FILM"
JOIN "PAGILA"."PAGILA"."FILM_CATEGORY" AS "FILM_CATEGORY"
ON "FILM"."film_id" = "FILM_CATEGORY"."film_id"
JOIN "PAGILA"."PAGILA"."CATEGORY" AS "CATEGORY"
ON "FILM_CATEGORY"."category_id" = "CATEGORY"."category_id"
WHERE "FILM"."film_id" IN (
    SELECT "film_id"
    FROM "PAGILA"."PAGILA"."INVENTORY"
    WHERE "inventory_id" IN (
        SELECT "inventory_id"
        FROM "PAGILA"."PAGILA"."RENTAL"
        WHERE "customer_id" IN (
            SELECT "customer_id"
            FROM "PAGILA"."PAGILA"."CUSTOMER"
            WHERE "address_id" IN (
                SELECT "address_id"
                FROM "PAGILA"."PAGILA"."ADDRESS"
                WHERE "city_id" IN (
                    SELECT "city_id"
                    FROM "PAGILA"."PAGILA"."CITY"
                    WHERE "city" ILIKE 'A%' OR "city" ILIKE '%-%'
                )
            )
        )
    )
)
GROUP BY "CATEGORY"."name"
ORDER BY SUM("FILM"."length") DESC NULLS LAST
LIMIT 1;