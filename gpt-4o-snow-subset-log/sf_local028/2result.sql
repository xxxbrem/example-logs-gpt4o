SELECT 
    CASE
        WHEN EXTRACT(MONTH FROM TO_TIMESTAMP("order_purchase_timestamp", 'YYYY-MM-DD HH24:MI:SS')) = 1 THEN 'January'
        WHEN EXTRACT(MONTH FROM TO_TIMESTAMP("order_purchase_timestamp", 'YYYY-MM-DD HH24:MI:SS')) = 2 THEN 'February'
        WHEN EXTRACT(MONTH FROM TO_TIMESTAMP("order_purchase_timestamp", 'YYYY-MM-DD HH24:MI:SS')) = 3 THEN 'March'
        WHEN EXTRACT(MONTH FROM TO_TIMESTAMP("order_purchase_timestamp", 'YYYY-MM-DD HH24:MI:SS')) = 4 THEN 'April'
        WHEN EXTRACT(MONTH FROM TO_TIMESTAMP("order_purchase_timestamp", 'YYYY-MM-DD HH24:MI:SS')) = 5 THEN 'May'
        WHEN EXTRACT(MONTH FROM TO_TIMESTAMP("order_purchase_timestamp", 'YYYY-MM-DD HH24:MI:SS')) = 6 THEN 'June'
        WHEN EXTRACT(MONTH FROM TO_TIMESTAMP("order_purchase_timestamp", 'YYYY-MM-DD HH24:MI:SS')) = 7 THEN 'July'
        WHEN EXTRACT(MONTH FROM TO_TIMESTAMP("order_purchase_timestamp", 'YYYY-MM-DD HH24:MI:SS')) = 8 THEN 'August'
        WHEN EXTRACT(MONTH FROM TO_TIMESTAMP("order_purchase_timestamp", 'YYYY-MM-DD HH24:MI:SS')) = 9 THEN 'September'
        WHEN EXTRACT(MONTH FROM TO_TIMESTAMP("order_purchase_timestamp", 'YYYY-MM-DD HH24:MI:SS')) = 10 THEN 'October'
        WHEN EXTRACT(MONTH FROM TO_TIMESTAMP("order_purchase_timestamp", 'YYYY-MM-DD HH24:MI:SS')) = 11 THEN 'November'
        WHEN EXTRACT(MONTH FROM TO_TIMESTAMP("order_purchase_timestamp", 'YYYY-MM-DD HH24:MI:SS')) = 12 THEN 'December'
    END AS "month_name",
    SUM(CASE WHEN EXTRACT(YEAR FROM TO_TIMESTAMP("order_purchase_timestamp", 'YYYY-MM-DD HH24:MI:SS')) = 2016 THEN 1 ELSE 0 END) AS "2016",
    SUM(CASE WHEN EXTRACT(YEAR FROM TO_TIMESTAMP("order_purchase_timestamp", 'YYYY-MM-DD HH24:MI:SS')) = 2017 THEN 1 ELSE 0 END) AS "2017",
    SUM(CASE WHEN EXTRACT(YEAR FROM TO_TIMESTAMP("order_purchase_timestamp", 'YYYY-MM-DD HH24:MI:SS')) = 2018 THEN 1 ELSE 0 END) AS "2018"
FROM "BRAZILIAN_E_COMMERCE"."BRAZILIAN_E_COMMERCE"."OLIST_ORDERS"
WHERE "order_status" = 'delivered'
GROUP BY 1
ORDER BY 
    CASE 
        WHEN "month_name" = 'January' THEN 1
        WHEN "month_name" = 'February' THEN 2
        WHEN "month_name" = 'March' THEN 3
        WHEN "month_name" = 'April' THEN 4
        WHEN "month_name" = 'May' THEN 5
        WHEN "month_name" = 'June' THEN 6
        WHEN "month_name" = 'July' THEN 7
        WHEN "month_name" = 'August' THEN 8
        WHEN "month_name" = 'September' THEN 9
        WHEN "month_name" = 'October' THEN 10
        WHEN "month_name" = 'November' THEN 11
        WHEN "month_name" = 'December' THEN 12
    END
LIMIT 12;