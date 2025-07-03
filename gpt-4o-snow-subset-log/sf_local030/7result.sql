WITH LowestPaymentCities AS (
    SELECT
        c."customer_city",
        SUM(p."payment_value") AS total_payments,
        COUNT(o."order_id") AS total_orders
    FROM BRAZILIAN_E_COMMERCE.BRAZILIAN_E_COMMERCE.OLIST_ORDERS o
    JOIN BRAZILIAN_E_COMMERCE.BRAZILIAN_E_COMMERCE.OLIST_CUSTOMERS c
        ON o."customer_id" = c."customer_id"
    JOIN BRAZILIAN_E_COMMERCE.BRAZILIAN_E_COMMERCE.OLIST_ORDER_PAYMENTS p
        ON o."order_id" = p."order_id"
    WHERE o."order_status" = 'delivered'
    GROUP BY c."customer_city"
    ORDER BY total_payments ASC
    LIMIT 5
)
SELECT
    AVG(total_payments) AS avg_total_payments,
    AVG(total_orders) AS avg_total_orders
FROM LowestPaymentCities;