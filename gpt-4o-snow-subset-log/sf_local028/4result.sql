SELECT 
    EXTRACT(MONTH FROM TO_TIMESTAMP("order_purchase_timestamp", 'YYYY-MM-DD HH24:MI:SS')) AS "month",
    SUM(CASE WHEN EXTRACT(YEAR FROM TO_TIMESTAMP("order_purchase_timestamp", 'YYYY-MM-DD HH24:MI:SS')) = 2016 THEN 1 ELSE 0 END) AS "2016_delivered_orders",
    SUM(CASE WHEN EXTRACT(YEAR FROM TO_TIMESTAMP("order_purchase_timestamp", 'YYYY-MM-DD HH24:MI:SS')) = 2017 THEN 1 ELSE 0 END) AS "2017_delivered_orders",
    SUM(CASE WHEN EXTRACT(YEAR FROM TO_TIMESTAMP("order_purchase_timestamp", 'YYYY-MM-DD HH24:MI:SS')) = 2018 THEN 1 ELSE 0 END) AS "2018_delivered_orders"
FROM "BRAZILIAN_E_COMMERCE"."BRAZILIAN_E_COMMERCE"."OLIST_ORDERS"
WHERE "order_status" = 'delivered'
GROUP BY EXTRACT(MONTH FROM TO_TIMESTAMP("order_purchase_timestamp", 'YYYY-MM-DD HH24:MI:SS'))
ORDER BY "month"
LIMIT 20;