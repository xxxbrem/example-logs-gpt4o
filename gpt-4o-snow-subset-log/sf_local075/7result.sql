SELECT 
    h."product_id", 
    h."page_name",
    SUM(CASE WHEN e."event_type" = 1 THEN 1 ELSE 0 END) AS "view_count",
    SUM(CASE WHEN e."event_type" = 2 THEN 1 ELSE 0 END) AS "add_to_cart_count",
    SUM(CASE WHEN e."event_type" = 2 AND NOT EXISTS (
        SELECT 1 
        FROM BANK_SALES_TRADING.BANK_SALES_TRADING.SHOPPING_CART_EVENTS p
        WHERE p."visit_id" = e."visit_id" 
          AND p."cookie_id" = e."cookie_id"
          AND p."event_type" = 3
    ) THEN 1 ELSE 0 END) AS "left_in_cart_count",
    SUM(CASE WHEN e."event_type" = 3 THEN 1 ELSE 0 END) AS "purchase_count"
FROM 
    BANK_SALES_TRADING.BANK_SALES_TRADING.SHOPPING_CART_PAGE_HIERARCHY h
JOIN 
    BANK_SALES_TRADING.BANK_SALES_TRADING.SHOPPING_CART_EVENTS e
    ON h."page_id" = e."page_id"
WHERE 
    e."page_id" NOT IN (1, 2, 12, 13)
GROUP BY 
    h."product_id", 
    h."page_name"
ORDER BY 
    "product_id" ASC;