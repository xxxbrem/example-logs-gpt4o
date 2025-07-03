SELECT 
    result."customer_id",
    result."number_of_orders",
    result."avg_payment_per_order",
    CASE 
        WHEN result."lifespan_days" < 7 THEN 1.0
        ELSE ROUND(result."lifespan_days" / 7.0, 1)
    END AS "lifespan_weeks"
FROM (
    SELECT 
        customer_stats."customer_id",
        customer_stats."number_of_orders",
        customer_stats."avg_payment_per_order",
        DATEDIFF(DAY, lifespan."first_purchase_date", lifespan."last_purchase_date") AS "lifespan_days"
    FROM (
        SELECT 
            o."customer_id",
            COUNT(o."order_id") AS "number_of_orders",
            AVG(SUM(p."payment_value")) OVER(PARTITION BY o."customer_id") AS "avg_payment_per_order"
        FROM "E_COMMERCE"."E_COMMERCE"."ORDERS" o
        JOIN "E_COMMERCE"."E_COMMERCE"."ORDER_PAYMENTS" p
          ON o."order_id" = p."order_id"
        GROUP BY o."customer_id", p."order_id"
    ) customer_stats
    JOIN (
        SELECT 
            o."customer_id",
            MIN(o."order_purchase_timestamp") AS "first_purchase_date",
            MAX(o."order_purchase_timestamp") AS "last_purchase_date"
        FROM "E_COMMERCE"."E_COMMERCE"."ORDERS" o
        GROUP BY o."customer_id"
    ) lifespan
    ON customer_stats."customer_id" = lifespan."customer_id"
) result
ORDER BY result."avg_payment_per_order" DESC NULLS LAST
LIMIT 3;