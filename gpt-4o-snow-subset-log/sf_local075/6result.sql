SELECT 
    ph."product_id", 
    ph."page_name",
    SUM(CASE WHEN e."event_type" = 1 THEN 1 ELSE 0 END) AS "view_count",
    SUM(CASE WHEN e."event_type" = 2 THEN 1 ELSE 0 END) AS "add_to_cart_count",
    SUM(CASE WHEN e."event_type" = 3 THEN 1 ELSE 0 END) AS "purchase_count",
    SUM(CASE 
        WHEN e."event_type" = 2 AND e."visit_id" NOT IN (
            SELECT DISTINCT e1."visit_id"
            FROM BANK_SALES_TRADING.BANK_SALES_TRADING.SHOPPING_CART_EVENTS e1
            WHERE e1."event_type" = 3
        ) 
        THEN 1 
        ELSE 0 
    END) AS "left_in_cart_count"
FROM BANK_SALES_TRADING.BANK_SALES_TRADING.SHOPPING_CART_PAGE_HIERARCHY ph
JOIN BANK_SALES_TRADING.BANK_SALES_TRADING.SHOPPING_CART_EVENTS e
ON ph."page_id" = e."page_id"
WHERE ph."page_id" NOT IN (1, 2, 12, 13)
GROUP BY ph."product_id", ph."page_name"
ORDER BY ph."product_id"
LIMIT 20;