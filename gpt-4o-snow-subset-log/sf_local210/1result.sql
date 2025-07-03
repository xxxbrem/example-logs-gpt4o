SELECT DISTINCT 
    h."hub_id", 
    h."hub_name", 
    h."hub_city", 
    h."hub_state"
FROM (
    SELECT feb."store_id", 
           ((mar."finished_orders_count_mar" - feb."finished_orders_count_feb") / NULLIF(feb."finished_orders_count_feb", 0)) * 100 AS "percentage_increase"
    FROM (
        SELECT "store_id", COUNT("order_id") AS "finished_orders_count_feb" 
        FROM DELIVERY_CENTER.DELIVERY_CENTER.ORDERS 
        WHERE "order_status" = 'FINISHED' AND "order_created_month" = 2 
        GROUP BY "store_id"
    ) feb 
    JOIN (
        SELECT "store_id", COUNT("order_id") AS "finished_orders_count_mar" 
        FROM DELIVERY_CENTER.DELIVERY_CENTER.ORDERS 
        WHERE "order_status" = 'FINISHED' AND "order_created_month" = 3 
        GROUP BY "store_id"
    ) mar 
    ON feb."store_id" = mar."store_id"
    WHERE ((mar."finished_orders_count_mar" - feb."finished_orders_count_feb") / NULLIF(feb."finished_orders_count_feb", 0)) * 100 > 20
) store_growth 
JOIN DELIVERY_CENTER.DELIVERY_CENTER.STORES s 
ON store_growth."store_id" = s."store_id"
JOIN DELIVERY_CENTER.DELIVERY_CENTER.HUBS h 
ON s."hub_id" = h."hub_id"
ORDER BY h."hub_id" ASC;