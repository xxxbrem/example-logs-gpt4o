SELECT 
    feb."hub_id", 
    feb."hub_name", 
    feb."finished_order_count" AS "feb_finished_orders",
    mar."finished_order_count" AS "mar_finished_orders",
    ((mar."finished_order_count" - feb."finished_order_count") * 100.0 / feb."finished_order_count") AS "percentage_increase"
FROM 
    (
        SELECT 
            COUNT(o."order_id") AS "finished_order_count", 
            h."hub_id", 
            h."hub_name"
        FROM 
            "DELIVERY_CENTER"."DELIVERY_CENTER"."ORDERS" o
        JOIN 
            "DELIVERY_CENTER"."DELIVERY_CENTER"."STORES" s 
        ON 
            o."store_id" = s."store_id"
        JOIN 
            "DELIVERY_CENTER"."DELIVERY_CENTER"."HUBS" h 
        ON 
            s."hub_id" = h."hub_id"
        WHERE 
            o."order_status" = 'FINISHED' 
            AND o."order_created_month" = 2 
            AND o."order_created_year" = 2021
        GROUP BY 
            h."hub_id", h."hub_name"
    ) feb
JOIN 
    (
        SELECT 
            COUNT(o."order_id") AS "finished_order_count", 
            h."hub_id", 
            h."hub_name"
        FROM 
            "DELIVERY_CENTER"."DELIVERY_CENTER"."ORDERS" o
        JOIN 
            "DELIVERY_CENTER"."DELIVERY_CENTER"."STORES" s 
        ON 
            o."store_id" = s."store_id"
        JOIN 
            "DELIVERY_CENTER"."DELIVERY_CENTER"."HUBS" h 
        ON 
            s."hub_id" = h."hub_id"
        WHERE 
            o."order_status" = 'FINISHED' 
            AND o."order_created_month" = 3 
            AND o."order_created_year" = 2021
        GROUP BY 
            h."hub_id", h."hub_name"
    ) mar
ON 
    feb."hub_id" = mar."hub_id"
WHERE 
    ((mar."finished_order_count" - feb."finished_order_count") * 100.0 / feb."finished_order_count") > 20
ORDER BY 
    "percentage_increase" DESC NULLS LAST;