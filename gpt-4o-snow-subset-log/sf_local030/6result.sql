WITH CityPaymentsAndOrders AS (
    -- Step 1: Retrieve the five cities with the lowest total payments for delivered orders.
    SELECT c."customer_city", 
           c."customer_state", 
           SUM(p."payment_value") AS "total_city_payment",
           COUNT(o."order_id") AS "delivered_order_count"
    FROM BRAZILIAN_E_COMMERCE.BRAZILIAN_E_COMMERCE.OLIST_CUSTOMERS c
    JOIN BRAZILIAN_E_COMMERCE.BRAZILIAN_E_COMMERCE.OLIST_ORDERS o
    ON c."customer_id" = o."customer_id"
    JOIN BRAZILIAN_E_COMMERCE.BRAZILIAN_E_COMMERCE.OLIST_ORDER_PAYMENTS p
    ON o."order_id" = p."order_id"
    WHERE o."order_status" = 'delivered'
    GROUP BY c."customer_city", c."customer_state"
    ORDER BY SUM(p."payment_value") ASC
    LIMIT 5
)
-- Step 2: Calculate the average of total payments and order counts for the selected cities.
SELECT AVG("total_city_payment") AS "average_total_payment", 
       AVG("delivered_order_count") AS "average_order_count"
FROM CityPaymentsAndOrders;