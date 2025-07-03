SELECT 
    p."product_id",
    p."page_name",
    COUNT(CASE WHEN e."event_type" = 1 THEN 1 END) AS "view_count",
    COUNT(CASE WHEN e."event_type" = 2 THEN 1 END) AS "add_to_cart_count",
    COUNT(CASE WHEN e."event_type" = 2 THEN 1 END) -
    COUNT(CASE WHEN e."event_type" = 3 THEN 1 END) AS "left_in_cart_count",
    COUNT(CASE WHEN e."event_type" = 3 THEN 1 END) AS "purchased_count"
FROM "BANK_SALES_TRADING"."BANK_SALES_TRADING"."SHOPPING_CART_EVENTS" e
JOIN "BANK_SALES_TRADING"."BANK_SALES_TRADING"."SHOPPING_CART_PAGE_HIERARCHY" p
ON e."page_id" = p."page_id"
WHERE p."page_id" NOT IN (1, 2, 12, 13)
GROUP BY p."product_id", p."page_name"
ORDER BY p."product_id";