WITH CustomerPayments AS (
    SELECT 
        o."customer_id", 
        COUNT(o."order_id") AS "total_orders", 
        SUM(op."payment_value") AS "total_payment",
        (SUM(op."payment_value") / COUNT(o."order_id")) AS "avg_payment_per_order"
    FROM E_COMMERCE.E_COMMERCE.ORDERS o
    JOIN E_COMMERCE.E_COMMERCE.ORDER_PAYMENTS op
    ON o."order_id" = op."order_id"
    GROUP BY o."customer_id"
),
CustomerLifespan AS (
    SELECT 
        "customer_id", 
        MIN("order_purchase_timestamp") AS "earliest_purchase", 
        MAX("order_purchase_timestamp") AS "latest_purchase",
        GREATEST(1.0, (DATEDIFF(DAY, MIN("order_purchase_timestamp"), MAX("order_purchase_timestamp")) / 7.0)) AS "customer_lifespan_weeks"
    FROM E_COMMERCE.E_COMMERCE.ORDERS
    GROUP BY "customer_id"
)
SELECT 
    p."customer_id", 
    p."total_orders", 
    p."avg_payment_per_order", 
    l."customer_lifespan_weeks"
FROM CustomerPayments p
JOIN CustomerLifespan l
ON p."customer_id" = l."customer_id"
ORDER BY p."avg_payment_per_order" DESC NULLS LAST
LIMIT 3;