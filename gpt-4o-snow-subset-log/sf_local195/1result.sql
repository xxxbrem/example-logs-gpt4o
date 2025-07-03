WITH total_customers AS (
    SELECT COUNT(DISTINCT "customer_id") AS "total_count"
    FROM SQLITE_SAKILA.SQLITE_SAKILA.CUSTOMER
),
customers_rented_top_actors AS (
    SELECT COUNT(DISTINCT "customer_id") AS "rented_count"
    FROM SQLITE_SAKILA.SQLITE_SAKILA.RENTAL
    WHERE "inventory_id" IN (
        SELECT DISTINCT "inventory_id"
        FROM SQLITE_SAKILA.SQLITE_SAKILA.INVENTORY
        WHERE "film_id" IN (
            SELECT DISTINCT "film_id"
            FROM SQLITE_SAKILA.SQLITE_SAKILA.FILM_ACTOR
            WHERE "actor_id" IN (1, 3, 4, 7, 8)
        )
    )
)
SELECT 
    (crta."rented_count" * 100.0 / tc."total_count") AS "percentage_customers_rented"
FROM customers_rented_top_actors crta
JOIN total_customers tc ON 1 = 1;