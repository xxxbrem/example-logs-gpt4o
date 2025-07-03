SELECT 
    TO_CHAR(TO_TIMESTAMP(o."created_at" / 1000000), 'YYYY-MM') AS "month",
    SUM(oi."sale_price") AS "total_sales",
    SUM(ii."cost") AS "total_cost",
    COUNT(DISTINCT o."order_id") AS "completed_orders",
    SUM(oi."sale_price" - ii."cost") AS "total_profit",
    CASE 
        WHEN SUM(ii."cost") = 0 THEN NULL 
        ELSE SUM(oi."sale_price" - ii."cost") / SUM(ii."cost") 
    END AS "profit_to_cost_ratio"
FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."ORDER_ITEMS" oi
JOIN "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."ORDERS" o
    ON oi."order_id" = o."order_id"
JOIN "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."INVENTORY_ITEMS" ii
    ON oi."inventory_item_id" = ii."id"
WHERE o."status" = 'Complete'
  AND oi."product_id" IN (
      SELECT "id"
      FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."PRODUCTS"
      WHERE "category" ILIKE '%Sleep%Lounge%'
  )
  AND o."created_at" BETWEEN 1672531200000000 AND 1704067199999999
GROUP BY 1
ORDER BY 1;