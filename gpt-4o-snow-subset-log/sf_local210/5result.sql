SELECT 
    "hub_id", 
    "hub_name", 
    "hub_city", 
    "hub_state", 
    "finished_orders_february", 
    "finished_orders_march", 
    "percentage_increase"
FROM (
    SELECT 
        s."hub_id", 
        h."hub_name", 
        h."hub_city", 
        h."hub_state", 
        SUM(CASE WHEN o."order_created_month" = 2 THEN 1 ELSE 0 END) AS "finished_orders_february",
        SUM(CASE WHEN o."order_created_month" = 3 THEN 1 ELSE 0 END) AS "finished_orders_march",
        CASE 
            WHEN SUM(CASE WHEN o."order_created_month" = 2 THEN 1 ELSE 0 END) = 0 THEN NULL
            ELSE (
                (
                    SUM(CASE WHEN o."order_created_month" = 3 THEN 1 ELSE 0 END) - 
                    SUM(CASE WHEN o."order_created_month" = 2 THEN 1 ELSE 0 END)
                ) * 1.0 / SUM(CASE WHEN o."order_created_month" = 2 THEN 1 ELSE 0 END)
            ) * 100
        END AS "percentage_increase"
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
        AND o."order_created_year" = 2021
    GROUP BY 
        s."hub_id", h."hub_name", h."hub_city", h."hub_state"
) subquery
WHERE 
    "percentage_increase" > 20
LIMIT 20;