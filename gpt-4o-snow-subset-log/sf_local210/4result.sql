SELECT 
    feb."hub_id",
    h."hub_name",
    feb."finished_orders_in_february",
    mar."finished_orders_in_march",
    ROUND(((mar."finished_orders_in_march" - feb."finished_orders_in_february") / feb."finished_orders_in_february" * 100), 4) AS "percentage_increase"
FROM 
    (SELECT 
         h."hub_id", 
         COUNT(o."order_id") AS "finished_orders_in_february"
     FROM 
         DELIVERY_CENTER.DELIVERY_CENTER.ORDERS o
     JOIN 
         DELIVERY_CENTER.DELIVERY_CENTER.STORES s 
     ON 
         o."store_id" = s."store_id"
     JOIN 
         DELIVERY_CENTER.DELIVERY_CENTER.HUBS h 
     ON 
         s."hub_id" = h."hub_id"
     WHERE 
         o."order_status" ILIKE '%FINISHED%' 
         AND o."order_created_month" = 2
     GROUP BY 
         h."hub_id") feb
JOIN 
    (SELECT 
         h."hub_id", 
         COUNT(o."order_id") AS "finished_orders_in_march"
     FROM 
         DELIVERY_CENTER.DELIVERY_CENTER.ORDERS o
     JOIN 
         DELIVERY_CENTER.DELIVERY_CENTER.STORES s 
     ON 
         o."store_id" = s."store_id"
     JOIN 
         DELIVERY_CENTER.DELIVERY_CENTER.HUBS h 
     ON 
         s."hub_id" = h."hub_id"
     WHERE 
         o."order_status" ILIKE '%FINISHED%' 
         AND o."order_created_month" = 3
     GROUP BY 
         h."hub_id") mar
ON 
    feb."hub_id" = mar."hub_id"
JOIN 
    DELIVERY_CENTER.DELIVERY_CENTER.HUBS h
ON 
    feb."hub_id" = h."hub_id"
WHERE 
    ((mar."finished_orders_in_march" - feb."finished_orders_in_february") / feb."finished_orders_in_february" * 100) > 20
ORDER BY 
    feb."hub_id";