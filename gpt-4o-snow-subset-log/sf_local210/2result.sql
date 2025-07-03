WITH finished_orders AS (
    SELECT s."hub_id", 
           o."order_created_month", 
           COUNT(*) AS "finished_orders"
    FROM "DELIVERY_CENTER"."DELIVERY_CENTER"."ORDERS" o
    JOIN "DELIVERY_CENTER"."DELIVERY_CENTER"."STORES" s
      ON o."store_id" = s."store_id"
    WHERE o."order_status" = 'FINISHED' AND o."order_created_month" IN (2, 3)
    GROUP BY s."hub_id", o."order_created_month"
),
percentage_increase AS (
    SELECT f1."hub_id",
           ROUND(((f2."finished_orders" - f1."finished_orders") * 100.0) / f1."finished_orders", 2) AS "percentage_increase"
    FROM finished_orders f1
    JOIN finished_orders f2
      ON f1."hub_id" = f2."hub_id" AND f1."order_created_month" = 2 AND f2."order_created_month" = 3
    WHERE f2."finished_orders" > f1."finished_orders"
)
SELECT h."hub_id", h."hub_name", h."hub_city", h."hub_state", pi."percentage_increase"
FROM percentage_increase pi
JOIN "DELIVERY_CENTER"."DELIVERY_CENTER"."HUBS" h
  ON pi."hub_id" = h."hub_id"
WHERE pi."percentage_increase" > 20
ORDER BY pi."percentage_increase" DESC
LIMIT 20;