WITH product_views AS (
    SELECT 
        p."product_id", 
        COUNT(e."event_type") AS "view_count"
    FROM "BANK_SALES_TRADING"."BANK_SALES_TRADING"."SHOPPING_CART_EVENTS" e
    JOIN "BANK_SALES_TRADING"."BANK_SALES_TRADING"."SHOPPING_CART_PAGE_HIERARCHY" p
        ON e."page_id" = p."page_id"
    WHERE e."event_type" = 1 AND e."page_id" NOT IN (1, 2, 12, 13)
    GROUP BY p."product_id"
),
product_add_to_cart AS (
    SELECT 
        p."product_id", 
        COUNT(e."event_type") AS "add_to_cart_count"
    FROM "BANK_SALES_TRADING"."BANK_SALES_TRADING"."SHOPPING_CART_EVENTS" e
    JOIN "BANK_SALES_TRADING"."BANK_SALES_TRADING"."SHOPPING_CART_PAGE_HIERARCHY" p
        ON e."page_id" = p."page_id"
    WHERE e."event_type" = 2 AND e."page_id" NOT IN (1, 2, 12, 13)
    GROUP BY p."product_id"
),
product_purchases AS (
    SELECT 
        p."product_id", 
        COUNT(e."event_type") AS "purchase_count"
    FROM "BANK_SALES_TRADING"."BANK_SALES_TRADING"."SHOPPING_CART_EVENTS" e
    JOIN "BANK_SALES_TRADING"."BANK_SALES_TRADING"."SHOPPING_CART_PAGE_HIERARCHY" p
        ON e."page_id" = p."page_id"
    WHERE e."event_type" = 3 AND e."page_id" NOT IN (1, 2, 12, 13)
    GROUP BY p."product_id"
)
SELECT 
    pv."product_id", 
    p."page_name", 
    COALESCE(pv."view_count", 0) AS "view_count", 
    COALESCE(pa."add_to_cart_count", 0) AS "add_to_cart_count", 
    COALESCE(pp."purchase_count", 0) AS "purchase_count",
    (COALESCE(pa."add_to_cart_count", 0) - COALESCE(pp."purchase_count", 0)) AS "left_in_cart_count"
FROM "BANK_SALES_TRADING"."BANK_SALES_TRADING"."SHOPPING_CART_PAGE_HIERARCHY" p
LEFT JOIN product_views pv ON p."product_id" = pv."product_id"
LEFT JOIN product_add_to_cart pa ON p."product_id" = pa."product_id"
LEFT JOIN product_purchases pp ON p."product_id" = pp."product_id"
WHERE p."page_id" NOT IN (1, 2, 12, 13)
ORDER BY p."product_id"
LIMIT 20;