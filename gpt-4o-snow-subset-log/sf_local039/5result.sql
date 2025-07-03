SELECT c."name" AS "category_name", fc."category_id", SUM(f."length") AS "total_rental_hours"
FROM "PAGILA"."PAGILA"."FILM_CATEGORY" fc
JOIN "PAGILA"."PAGILA"."CATEGORY" c
ON fc."category_id" = c."category_id"
JOIN "PAGILA"."PAGILA"."FILM" f
ON fc."film_id" = f."film_id"
WHERE fc."film_id" IN (
    SELECT DISTINCT i."film_id"
    FROM "PAGILA"."PAGILA"."RENTAL" r
    JOIN "PAGILA"."PAGILA"."INVENTORY" i
    ON r."inventory_id" = i."inventory_id"
    WHERE r."customer_id" IN (
        SELECT DISTINCT cu."customer_id"
        FROM "PAGILA"."PAGILA"."CUSTOMER" cu
        WHERE cu."address_id" IN (
            SELECT DISTINCT a."address_id"
            FROM "PAGILA"."PAGILA"."ADDRESS" a
            WHERE a."city_id" IN (
                SELECT ci."city_id"
                FROM "PAGILA"."PAGILA"."CITY" ci
                WHERE ci."city" ILIKE 'A%' OR ci."city" ILIKE '%-%'
            )
        )
    )
)
GROUP BY fc."category_id", c."name"
ORDER BY SUM(f."length") DESC NULLS LAST
LIMIT 1;