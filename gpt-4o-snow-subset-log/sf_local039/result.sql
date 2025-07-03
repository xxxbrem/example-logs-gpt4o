SELECT 
    fc."category_id",
    c."name" AS "category_name",
    SUM(f."length") AS "total_rental_hours"
FROM "PAGILA"."PAGILA"."FILM_CATEGORY" fc
JOIN "PAGILA"."PAGILA"."FILM" f
    ON fc."film_id" = f."film_id"
JOIN "PAGILA"."PAGILA"."CATEGORY" c
    ON fc."category_id" = c."category_id"
WHERE fc."film_id" IN (
    SELECT DISTINCT i."film_id"
    FROM "PAGILA"."PAGILA"."INVENTORY" i
    JOIN "PAGILA"."PAGILA"."RENTAL" r
        ON r."inventory_id" = i."inventory_id"
    WHERE r."customer_id" IN (
        SELECT DISTINCT cu."customer_id"
        FROM "PAGILA"."PAGILA"."CUSTOMER" cu
        JOIN "PAGILA"."PAGILA"."ADDRESS" a
            ON cu."address_id" = a."address_id"
        WHERE a."city_id" IN (
            SELECT DISTINCT "city_id"
            FROM "PAGILA"."PAGILA"."CITY"
            WHERE "city" ILIKE 'A%' OR "city" ILIKE '%-%'
        )
    )
)
GROUP BY fc."category_id", c."name"
ORDER BY SUM(f."length") DESC NULLS LAST
LIMIT 1;