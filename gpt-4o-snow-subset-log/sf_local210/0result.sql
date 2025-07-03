WITH feb_counts AS (
    SELECT 
        s."hub_id", 
        COUNT(o."order_id") AS "finished_orders_feb"
    FROM 
        "DELIVERY_CENTER"."DELIVERY_CENTER"."ORDERS" o
    JOIN 
        "DELIVERY_CENTER"."DELIVERY_CENTER"."STORES" s 
    ON 
        o."store_id" = s."store_id"
    WHERE 
        o."order_status" = 'FINISHED' 
        AND o."order_created_month" = 2
    GROUP BY 
        s."hub_id"
), 
mar_counts AS (
    SELECT 
        s."hub_id", 
        COUNT(o."order_id") AS "finished_orders_mar"
    FROM 
        "DELIVERY_CENTER"."DELIVERY_CENTER"."ORDERS" o
    JOIN 
        "DELIVERY_CENTER"."DELIVERY_CENTER"."STORES" s 
    ON 
        o."store_id" = s."store_id"
    WHERE 
        o."order_status" = 'FINISHED' 
        AND o."order_created_month" = 3
    GROUP BY 
        s."hub_id"
)
SELECT 
    feb_counts."hub_id", 
    feb_counts."finished_orders_feb", 
    mar_counts."finished_orders_mar", 
    ((mar_counts."finished_orders_mar" - feb_counts."finished_orders_feb") * 100.0 / feb_counts."finished_orders_feb") AS "percent_increase"
FROM 
    feb_counts
JOIN 
    mar_counts 
ON 
    feb_counts."hub_id" = mar_counts."hub_id"
WHERE 
    ((mar_counts."finished_orders_mar" - feb_counts."finished_orders_feb") * 100.0 / feb_counts."finished_orders_feb") > 20
ORDER BY 
    "percent_increase" DESC NULLS LAST
LIMIT 20;