SELECT h."hub_id", h."hub_name", h."hub_city", 
       COALESCE(feb."finished_orders_count", 0) AS "feb_finished_orders",
       COALESCE(mar."finished_orders_count", 0) AS "mar_finished_orders",
       ((COALESCE(mar."finished_orders_count", 0) - COALESCE(feb."finished_orders_count", 0)) * 100.0 / COALESCE(feb."finished_orders_count", 0)) AS "percentage_increase"
FROM DELIVERY_CENTER.DELIVERY_CENTER.HUBS h
LEFT JOIN (
    SELECT s."hub_id", COUNT(o."order_id") AS "finished_orders_count"
    FROM DELIVERY_CENTER.DELIVERY_CENTER.ORDERS o
    JOIN DELIVERY_CENTER.DELIVERY_CENTER.STORES s ON o."store_id" = s."store_id"
    WHERE o."order_status" = 'FINISHED' AND o."order_created_month" = 2
    GROUP BY s."hub_id"
) feb ON h."hub_id" = feb."hub_id"
LEFT JOIN (
    SELECT s."hub_id", COUNT(o."order_id") AS "finished_orders_count"
    FROM DELIVERY_CENTER.DELIVERY_CENTER.ORDERS o
    JOIN DELIVERY_CENTER.DELIVERY_CENTER.STORES s ON o."store_id" = s."store_id"
    WHERE o."order_status" = 'FINISHED' AND o."order_created_month" = 3
    GROUP BY s."hub_id"
) mar ON h."hub_id" = mar."hub_id"
WHERE COALESCE(feb."finished_orders_count", 0) > 0 -- Prevents division by zero
      AND ((COALESCE(mar."finished_orders_count", 0) - COALESCE(feb."finished_orders_count", 0)) * 100.0 / COALESCE(feb."finished_orders_count", 0)) > 20
ORDER BY "percentage_increase" DESC NULLS LAST
LIMIT 20;