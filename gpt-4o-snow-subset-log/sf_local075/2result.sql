WITH product_views AS (
  SELECT 
    h."product_id", 
    h."page_name", 
    h."product_category", 
    COUNT(*) AS "view_count"
  FROM BANK_SALES_TRADING.BANK_SALES_TRADING.SHOPPING_CART_EVENTS e
  JOIN BANK_SALES_TRADING.BANK_SALES_TRADING.SHOPPING_CART_PAGE_HIERARCHY h
    ON e."page_id" = h."page_id"
  JOIN BANK_SALES_TRADING.BANK_SALES_TRADING.SHOPPING_CART_EVENT_IDENTIFIER i
    ON e."event_type" = i."event_type"
  WHERE i."event_name" = 'Page View'
    AND e."page_id" NOT IN (1, 2, 12, 13)
  GROUP BY h."product_id", h."page_name", h."product_category"
),
added_to_cart AS (
  SELECT 
    h."product_id", 
    h."page_name", 
    h."product_category", 
    COUNT(*) AS "added_to_cart_count"
  FROM BANK_SALES_TRADING.BANK_SALES_TRADING.SHOPPING_CART_EVENTS e
  JOIN BANK_SALES_TRADING.BANK_SALES_TRADING.SHOPPING_CART_PAGE_HIERARCHY h
    ON e."page_id" = h."page_id"
  JOIN BANK_SALES_TRADING.BANK_SALES_TRADING.SHOPPING_CART_EVENT_IDENTIFIER i
    ON e."event_type" = i."event_type"
  WHERE i."event_name" = 'Add to Cart'
    AND e."page_id" NOT IN (1, 2, 12, 13)
  GROUP BY h."product_id", h."page_name", h."product_category"
),
purchases AS (
  SELECT 
    h."product_id", 
    h."page_name", 
    h."product_category", 
    COUNT(*) AS "purchase_count"
  FROM BANK_SALES_TRADING.BANK_SALES_TRADING.SHOPPING_CART_EVENTS e
  JOIN BANK_SALES_TRADING.BANK_SALES_TRADING.SHOPPING_CART_PAGE_HIERARCHY h
    ON e."page_id" = h."page_id"
  JOIN BANK_SALES_TRADING.BANK_SALES_TRADING.SHOPPING_CART_EVENT_IDENTIFIER i
    ON e."event_type" = i."event_type"
  WHERE i."event_name" = 'Purchase'
    AND e."page_id" NOT IN (1, 2, 12, 13)
  GROUP BY h."product_id", h."page_name", h."product_category"
),
left_in_cart AS (
  SELECT 
    a."product_id", 
    a."page_name", 
    a."product_category", 
    COUNT(*) AS "left_in_cart_count"
  FROM (
    SELECT h."product_id", h."page_name", h."product_category", e."cookie_id"
    FROM BANK_SALES_TRADING.BANK_SALES_TRADING.SHOPPING_CART_EVENTS e
    JOIN BANK_SALES_TRADING.BANK_SALES_TRADING.SHOPPING_CART_PAGE_HIERARCHY h
      ON e."page_id" = h."page_id"
    JOIN BANK_SALES_TRADING.BANK_SALES_TRADING.SHOPPING_CART_EVENT_IDENTIFIER i
      ON e."event_type" = i."event_type"
    WHERE i."event_name" = 'Add to Cart'
      AND e."page_id" NOT IN (1, 2, 12, 13)
  ) a
  LEFT JOIN (
    SELECT h."product_id", e."cookie_id"
    FROM BANK_SALES_TRADING.BANK_SALES_TRADING.SHOPPING_CART_EVENTS e
    JOIN BANK_SALES_TRADING.BANK_SALES_TRADING.SHOPPING_CART_PAGE_HIERARCHY h
      ON e."page_id" = h."page_id"
    JOIN BANK_SALES_TRADING.BANK_SALES_TRADING.SHOPPING_CART_EVENT_IDENTIFIER i
      ON e."event_type" = i."event_type"
    WHERE i."event_name" = 'Purchase'
      AND e."page_id" NOT IN (1, 2, 12, 13)
  ) p
  ON a."product_id" = p."product_id" AND a."cookie_id" = p."cookie_id"
  WHERE p."product_id" IS NULL
  GROUP BY a."product_id", a."page_name", a."product_category"
)
SELECT 
  COALESCE(v."product_id", c."product_id", p."product_id", l."product_id") AS "product_id",
  COALESCE(v."page_name", c."page_name", p."page_name", l."page_name") AS "page_name",
  COALESCE(v."product_category", c."product_category", p."product_category", l."product_category") AS "product_category",
  COALESCE(v."view_count", 0) AS "view_count",
  COALESCE(c."added_to_cart_count", 0) AS "added_to_cart_count",
  COALESCE(l."left_in_cart_count", 0) AS "left_in_cart_count",
  COALESCE(p."purchase_count", 0) AS "purchase_count"
FROM product_views v
FULL OUTER JOIN added_to_cart c ON v."product_id" = c."product_id"
FULL OUTER JOIN purchases p ON v."product_id" = p."product_id"
FULL OUTER JOIN left_in_cart l ON v."product_id" = l."product_id"
ORDER BY "product_id";