WITH ProductViews AS (
  SELECT e."page_id", COUNT(*) AS "view_count"
  FROM BANK_SALES_TRADING.BANK_SALES_TRADING.SHOPPING_CART_EVENTS e
  WHERE e."event_type" = 1
  GROUP BY e."page_id"
),
AddToCart AS (
  SELECT e."page_id", COUNT(*) AS "add_to_cart_count"
  FROM BANK_SALES_TRADING.BANK_SALES_TRADING.SHOPPING_CART_EVENTS e
  WHERE e."event_type" = 2
  GROUP BY e."page_id"
),
Purchases AS (
  SELECT e."page_id", COUNT(*) AS "purchase_count"
  FROM BANK_SALES_TRADING.BANK_SALES_TRADING.SHOPPING_CART_EVENTS e
  WHERE e."event_type" = 3
  GROUP BY e."page_id"
),
PageInfo AS (
  SELECT p."page_id", p."product_id", p."page_name", p."product_category"
  FROM BANK_SALES_TRADING.BANK_SALES_TRADING.SHOPPING_CART_PAGE_HIERARCHY p
  WHERE p."page_id" NOT IN (1, 2, 12, 13)
)
SELECT pf."product_id", pf."page_name", pf."product_category",
       COALESCE(v."view_count", 0) AS "view_count",
       COALESCE(a."add_to_cart_count", 0) AS "add_to_cart_count",
       (COALESCE(a."add_to_cart_count", 0) - COALESCE(pu."purchase_count", 0)) AS "left_in_cart_count",
       COALESCE(pu."purchase_count", 0) AS "purchase_count"
FROM PageInfo pf
LEFT JOIN ProductViews v ON pf."page_id" = v."page_id"
LEFT JOIN AddToCart a ON pf."page_id" = a."page_id"
LEFT JOIN Purchases pu ON pf."page_id" = pu."page_id"
ORDER BY pf."product_id"
LIMIT 20;