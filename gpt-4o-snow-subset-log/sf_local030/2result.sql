WITH CityPayments AS (
    SELECT 
        c."customer_city", 
        SUM(p."payment_value") AS total_payment_value, 
        COUNT(o."order_id") AS total_delivered_orders
    FROM BRAZILIAN_E_COMMERCE.BRAZILIAN_E_COMMERCE.OLIST_ORDERS o
    JOIN BRAZILIAN_E_COMMERCE.BRAZILIAN_E_COMMERCE.OLIST_ORDER_PAYMENTS p 
        ON o."order_id" = p."order_id"
    JOIN BRAZILIAN_E_COMMERCE.BRAZILIAN_E_COMMERCE.OLIST_CUSTOMERS c 
        ON o."customer_id" = c."customer_id"
    WHERE o."order_status" = 'delivered'
    GROUP BY c."customer_city"
    ORDER BY total_payment_value ASC
    LIMIT 5
)
SELECT 
    AVG(total_payment_value) AS avg_payment_value, 
    AVG(total_delivered_orders) AS avg_order_count
FROM CityPayments;