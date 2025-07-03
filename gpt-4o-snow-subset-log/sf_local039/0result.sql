SELECT 
    fc."category_id",
    c."name" AS "category_name",
    SUM(f."length") AS "total_rental_hours"
FROM 
    "PAGILA"."PAGILA"."FILM_CATEGORY" fc
JOIN 
    "PAGILA"."PAGILA"."FILM" f ON fc."film_id" = f."film_id"
JOIN 
    "PAGILA"."PAGILA"."CATEGORY" c ON fc."category_id" = c."category_id"
WHERE 
    fc."film_id" IN (
        SELECT DISTINCT i."film_id"
        FROM "PAGILA"."PAGILA"."INVENTORY" i
        WHERE i."inventory_id" IN (
            SELECT DISTINCT r."inventory_id"
            FROM "PAGILA"."PAGILA"."RENTAL" r
            WHERE r."customer_id" IN (
                SELECT DISTINCT cu."customer_id"
                FROM "PAGILA"."PAGILA"."CUSTOMER" cu
                WHERE cu."address_id" IN (
                    SELECT DISTINCT a."address_id"
                    FROM "PAGILA"."PAGILA"."ADDRESS" a
                    WHERE a."city_id" IN (
                        SELECT DISTINCT ci."city_id"
                        FROM "PAGILA"."PAGILA"."CITY" ci
                        WHERE ci."city" ILIKE 'A%' OR ci."city" ILIKE '%-%'
                    )
                )
            )
        )
    )
GROUP BY 
    fc."category_id", c."name"
ORDER BY 
    "total_rental_hours" DESC NULLS LAST
LIMIT 1;