SELECT DATE_TRUNC('month', (o."created_at" / 1000000)::TIMESTAMP) AS "month", 
       u."country", 
       i."product_department", 
       i."product_category", 
       COUNT(DISTINCT o."order_id") AS "num_of_orders",
       COUNT(DISTINCT u."id") AS "unique_purchasers", 
       SUM(p."retail_price") - SUM(i."cost") AS "profit"
FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."ORDERS" o
JOIN "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."USERS" u 
  ON o."user_id" = u."id"
JOIN "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."ORDER_ITEMS" oi 
  ON o."order_id" = oi."order_id"
JOIN "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."INVENTORY_ITEMS" i 
  ON oi."inventory_item_id" = i."id"
JOIN "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."PRODUCTS" p 
  ON i."product_id" = p."id"
WHERE (o."created_at" / 1000000)::TIMESTAMP BETWEEN '2021-01-01' AND '2021-12-31'
  AND (u."created_at" / 1000000)::TIMESTAMP BETWEEN '2021-01-01' AND '2021-12-31'
  AND (i."created_at" / 1000000)::TIMESTAMP BETWEEN '2021-01-01' AND '2021-12-31'
GROUP BY DATE_TRUNC('month', (o."created_at" / 1000000)::TIMESTAMP), u."country", i."product_department", i."product_category"
ORDER BY "month" ASC
LIMIT 20;