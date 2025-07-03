WITH avg_payment_per_customer AS (
    SELECT 
        o."customer_id", 
        AVG(SUM(op."payment_value")) OVER (PARTITION BY o."customer_id") AS "avg_payment"
    FROM 
        E_COMMERCE.E_COMMERCE.ORDER_PAYMENTS op
    JOIN 
        E_COMMERCE.E_COMMERCE.ORDERS o
    ON 
        op."order_id" = o."order_id"
    GROUP BY 
        o."customer_id", 
        o."order_id"
),
top_customers AS (
    SELECT 
        "customer_id", 
        "avg_payment"
    FROM 
        avg_payment_per_customer
    ORDER BY 
        "avg_payment" DESC NULLS LAST
    LIMIT 3
),
customer_order_counts AS (
    SELECT 
        o."customer_id", 
        COUNT(DISTINCT o."order_id") AS "order_count"
    FROM 
        E_COMMERCE.E_COMMERCE.ORDERS o
    GROUP BY 
        o."customer_id"
),
customer_lifespan AS (
    SELECT 
        o."customer_id", 
        CASE 
            WHEN DATEDIFF(DAY, MIN(o."order_purchase_timestamp"), MAX(o."order_purchase_timestamp")) < 7 THEN 1.0
            ELSE ROUND(DATEDIFF(DAY, MIN(o."order_purchase_timestamp"), MAX(o."order_purchase_timestamp")) / 7.0, 2)
        END AS "lifespan_weeks"
    FROM 
        E_COMMERCE.E_COMMERCE.ORDERS o
    GROUP BY 
        o."customer_id"
)
SELECT 
    tc."customer_id", 
    oc."order_count", 
    tc."avg_payment", 
    cl."lifespan_weeks"
FROM 
    top_customers tc
JOIN 
    customer_order_counts oc
ON 
    tc."customer_id" = oc."customer_id"
JOIN 
    customer_lifespan cl
ON 
    tc."customer_id" = cl."customer_id";