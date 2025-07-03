SELECT 
    TO_CHAR(TO_DATE(SUBSTRING("order_purchase_timestamp", 1, 10), 'YYYY-MM-DD'), 'MM') AS "month",
    SUM(CASE WHEN TO_CHAR(TO_DATE(SUBSTRING("order_purchase_timestamp", 1, 10), 'YYYY-MM-DD'), 'YYYY') = '2016' THEN 1 ELSE 0 END) AS "2016",
    SUM(CASE WHEN TO_CHAR(TO_DATE(SUBSTRING("order_purchase_timestamp", 1, 10), 'YYYY-MM-DD'), 'YYYY') = '2017' THEN 1 ELSE 0 END) AS "2017",
    SUM(CASE WHEN TO_CHAR(TO_DATE(SUBSTRING("order_purchase_timestamp", 1, 10), 'YYYY-MM-DD'), 'YYYY') = '2018' THEN 1 ELSE 0 END) AS "2018"
FROM 
    "BRAZILIAN_E_COMMERCE"."BRAZILIAN_E_COMMERCE"."OLIST_ORDERS"
WHERE 
    "order_status" ILIKE 'delivered'
GROUP BY 
    "month"
ORDER BY 
    "month";