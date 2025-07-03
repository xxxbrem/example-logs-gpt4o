WITH february_orders AS (
    SELECT s."hub_id", COUNT(o."order_id") AS "finished_orders_february"
    FROM DELIVERY_CENTER.DELIVERY_CENTER.ORDERS o
    JOIN DELIVERY_CENTER.DELIVERY_CENTER.STORES s
    ON o."store_id" = s."store_id"
    WHERE o."order_created_month" = 2 AND o."order_created_year" = 2021 AND o."order_status" = 'FINISHED'
    GROUP BY s."hub_id"
),
march_orders AS (
    SELECT s."hub_id", COUNT(o."order_id") AS "finished_orders_march"
    FROM DELIVERY_CENTER.DELIVERY_CENTER.ORDERS o
    JOIN DELIVERY_CENTER.DELIVERY_CENTER.STORES s
    ON o."store_id" = s."store_id"
    WHERE o."order_created_month" = 3 AND o."order_created_year" = 2021 AND o."order_status" = 'FINISHED'
    GROUP BY s."hub_id"
)
SELECT f."hub_id", f."finished_orders_february", m."finished_orders_march",
       ((m."finished_orders_march" - f."finished_orders_february") * 100.0 / f."finished_orders_february") AS "percentage_increase",
       h."hub_name", h."hub_city", h."hub_state"
FROM february_orders f
JOIN march_orders m
ON f."hub_id" = m."hub_id"
JOIN DELIVERY_CENTER.DELIVERY_CENTER.HUBS h
ON f."hub_id" = h."hub_id"
WHERE ((m."finished_orders_march" - f."finished_orders_february") * 100.0 / f."finished_orders_february") > 20
ORDER BY "percentage_increase" DESC
LIMIT 20;