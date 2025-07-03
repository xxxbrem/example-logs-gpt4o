WITH customer_metrics AS (
    SELECT 
        o."customer_id", 
        COUNT(DISTINCT o."order_id") AS "num_orders", 
        SUM(p."payment_value") / COUNT(DISTINCT o."order_id") AS "avg_payment_per_order", 
        CASE 
            WHEN DATEDIFF(DAY, MIN(o."order_purchase_timestamp"), MAX(o."order_purchase_timestamp")) / 7.0 < 1.0 THEN 1.0
            ELSE DATEDIFF(DAY, MIN(o."order_purchase_timestamp"), MAX(o."order_purchase_timestamp")) / 7.0
        END AS "customer_lifespan_in_weeks"
    FROM 
        E_COMMERCE.E_COMMERCE.ORDERS o
    JOIN 
        E_COMMERCE.E_COMMERCE.ORDER_PAYMENTS p
    ON 
        o."order_id" = p."order_id"
    GROUP BY 
        o."customer_id"
),
top_3_customers AS (
    SELECT 
        *
    FROM 
        customer_metrics
    ORDER BY 
        "avg_payment_per_order" DESC NULLS LAST
    LIMIT 3
)
SELECT 
    "customer_id", 
    "num_orders", 
    "avg_payment_per_order", 
    "customer_lifespan_in_weeks"
FROM 
    top_3_customers;