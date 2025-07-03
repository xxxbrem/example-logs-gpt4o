SELECT 
    EXTRACT(MONTH FROM TO_TIMESTAMP("order_purchase_timestamp", 'YYYY-MM-DD HH24:MI:SS')) AS "month",
    COUNT(CASE WHEN EXTRACT(YEAR FROM TO_TIMESTAMP("order_purchase_timestamp", 'YYYY-MM-DD HH24:MI:SS')) = 2016 THEN "order_id" END) AS "2016",
    COUNT(CASE WHEN EXTRACT(YEAR FROM TO_TIMESTAMP("order_purchase_timestamp", 'YYYY-MM-DD HH24:MI:SS')) = 2017 THEN "order_id" END) AS "2017",
    COUNT(CASE WHEN EXTRACT(YEAR FROM TO_TIMESTAMP("order_purchase_timestamp", 'YYYY-MM-DD HH24:MI:SS')) = 2018 THEN "order_id" END) AS "2018"
FROM 
    "BRAZILIAN_E_COMMERCE"."BRAZILIAN_E_COMMERCE"."OLIST_ORDERS"
WHERE 
    "order_status" = 'delivered'
GROUP BY 
    EXTRACT(MONTH FROM TO_TIMESTAMP("order_purchase_timestamp", 'YYYY-MM-DD HH24:MI:SS'))
ORDER BY 
    "month";