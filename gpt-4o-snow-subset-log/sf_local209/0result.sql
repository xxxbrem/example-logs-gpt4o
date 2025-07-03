WITH StoreOrderCounts AS (
  SELECT 
    o."store_id", 
    s."store_name", 
    COUNT(*) AS "total_orders"
  FROM "DELIVERY_CENTER"."DELIVERY_CENTER"."ORDERS" o
  JOIN "DELIVERY_CENTER"."DELIVERY_CENTER"."STORES" s
  ON o."store_id" = s."store_id"
  GROUP BY o."store_id", s."store_name"
  ORDER BY "total_orders" DESC NULLS LAST
  LIMIT 1
),
DeliveredOrdersCount AS (
  SELECT 
    COUNT(*) AS "delivered_orders"
  FROM "DELIVERY_CENTER"."DELIVERY_CENTER"."DELIVERIES" d
  WHERE d."delivery_status" = 'DELIVERED'
  AND d."delivery_order_id" IN (
    SELECT DISTINCT o."delivery_order_id"
    FROM "DELIVERY_CENTER"."DELIVERY_CENTER"."ORDERS" o
    WHERE o."store_id" = (SELECT "store_id" FROM StoreOrderCounts)
  )
),
TotalOrdersCount AS (
  SELECT 
    COUNT(*) AS "total_orders"
  FROM "DELIVERY_CENTER"."DELIVERY_CENTER"."ORDERS" o
  WHERE o."store_id" = (SELECT "store_id" FROM StoreOrderCounts)
),
DeliveryRatio AS (
  SELECT 
    (CAST((SELECT "delivered_orders" FROM DeliveredOrdersCount) AS FLOAT) / 
     (SELECT "total_orders" FROM TotalOrdersCount)) AS "delivered_to_total_ratio"
)
SELECT 
  StoreOrderCounts."store_id",
  StoreOrderCounts."store_name",
  StoreOrderCounts."total_orders",
  DeliveryRatio."delivered_to_total_ratio"
FROM StoreOrderCounts, DeliveryRatio;