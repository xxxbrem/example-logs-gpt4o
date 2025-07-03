SELECT 
    DATE_TRUNC('month', TO_TIMESTAMP(o."created_at" / 1e6)) AS "month",
    SUM(oi."sale_price") AS "total_sales",
    SUM(ii."cost") AS "total_cost",
    COUNT(DISTINCT oi."order_id") AS "complete_orders",
    (SUM(oi."sale_price") - SUM(ii."cost")) AS "profit",
    (SUM(oi."sale_price") - SUM(ii."cost")) / NULLIF(SUM(ii."cost"), 0) AS "profit_margin"
FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."ORDER_ITEMS" oi
JOIN "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."INVENTORY_ITEMS" ii
  ON oi."inventory_item_id" = ii."id"
JOIN "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."ORDERS" o
  ON oi."order_id" = o."order_id"
WHERE ii."product_category" ILIKE '%Sleep%Lounge%'
  AND o."status" = 'Complete'
  AND o."created_at" >= 1672531200000000 -- January 1, 2023 in microseconds
  AND o."created_at" <= 1704067199000000 -- December 31, 2023, 11:59:59 PM in microseconds
GROUP BY 1
ORDER BY 1;