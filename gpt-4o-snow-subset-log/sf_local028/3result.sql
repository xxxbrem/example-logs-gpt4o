SELECT 
    SUBSTRING("order_purchase_timestamp", 6, 2) AS "month",
    SUM(CASE WHEN SUBSTRING("order_purchase_timestamp", 1, 4) = '2016' THEN 1 ELSE 0 END) AS "2016",
    SUM(CASE WHEN SUBSTRING("order_purchase_timestamp", 1, 4) = '2017' THEN 1 ELSE 0 END) AS "2017",
    SUM(CASE WHEN SUBSTRING("order_purchase_timestamp", 1, 4) = '2018' THEN 1 ELSE 0 END) AS "2018"
FROM "BRAZILIAN_E_COMMERCE"."BRAZILIAN_E_COMMERCE"."OLIST_ORDERS"
WHERE "order_status" = 'delivered'
GROUP BY 1
ORDER BY 1;