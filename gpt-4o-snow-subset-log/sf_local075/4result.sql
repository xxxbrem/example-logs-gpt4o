WITH EventDetails AS (
  -- Join events with event names and page/product details while filtering out invalid pages
  SELECT 
    e."cookie_id",
    p."product_id",
    p."page_name" AS "product_name",
    p."product_category",
    i."event_name",
    e."event_time"
  FROM BANK_SALES_TRADING.BANK_SALES_TRADING.SHOPPING_CART_EVENTS e
  JOIN BANK_SALES_TRADING.BANK_SALES_TRADING.SHOPPING_CART_EVENT_IDENTIFIER i 
    ON e."event_type" = i."event_type"
  JOIN BANK_SALES_TRADING.BANK_SALES_TRADING.SHOPPING_CART_PAGE_HIERARCHY p 
    ON e."page_id" = p."page_id"
  WHERE e."page_id" NOT IN (1, 2, 12, 13)
),
ProductEventCounts AS (
  -- Calculate counts for each type of event for each product
  SELECT 
    "product_id",
    "product_name",
    COUNT(CASE WHEN "event_name" = 'Page View' THEN 1 END) AS "view_count",
    COUNT(CASE WHEN "event_name" = 'Add to Cart' THEN 1 END) AS "add_to_cart_count",
    COUNT(CASE WHEN "event_name" = 'Purchase' THEN 1 END) AS "purchase_count"
  FROM EventDetails
  GROUP BY "product_id", "product_name"
),
LeftInCartCounts AS (
  -- Calculate how many times items were left in the cart without being purchased
  SELECT 
    e."product_id",
    e."product_name",
    (e."add_to_cart_count" - e."purchase_count") AS "left_in_cart_count"
  FROM ProductEventCounts e
)
-- Combine counts to get a complete breakdown per product
SELECT 
  p."product_id",
  p."product_name",
  p."view_count",
  p."add_to_cart_count",
  l."left_in_cart_count",
  p."purchase_count"
FROM ProductEventCounts p
JOIN LeftInCartCounts l 
  ON p."product_id" = l."product_id"
ORDER BY p."product_id";