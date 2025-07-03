WITH UserData_2021 AS (
    SELECT "id" AS "user_id", "country"
    FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."USERS"
    WHERE "created_at" BETWEEN 1609459200000000 AND 1640995200000000
),
OrdersData_2021 AS (
    SELECT "order_id", "user_id", "created_at"
    FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."ORDERS"
    WHERE "created_at" BETWEEN 1609459200000000 AND 1640995200000000
),
InventoryData_2021 AS (
    SELECT "id" AS "inventory_item_id", "product_id", "product_department", "product_category", "cost", "created_at"
    FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."INVENTORY_ITEMS"
    WHERE "created_at" BETWEEN 1609459200000000 AND 1640995200000000
),
OrderItems_2021 AS (
    SELECT oi."order_id", oi."inventory_item_id", oi."user_id", i."product_id"
    FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."ORDER_ITEMS" oi
    JOIN OrdersData_2021 o ON oi."order_id" = o."order_id"
    JOIN InventoryData_2021 i ON oi."inventory_item_id" = i."inventory_item_id"
),
ProductsData AS (
    SELECT "id" AS "product_id", "retail_price"
    FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."PRODUCTS"
),
AggregatedData AS (
    SELECT 
        TO_CHAR(TO_TIMESTAMP(o."created_at" / 1000000), 'YYYY-MM') AS "month",
        u."country",
        i."product_department",
        i."product_category",
        COUNT(DISTINCT o."order_id") AS "num_orders",
        COUNT(DISTINCT o."user_id") AS "num_unique_purchasers",
        SUM(p."retail_price" - i."cost") AS "profit"
    FROM OrdersData_2021 o
    JOIN UserData_2021 u ON o."user_id" = u."user_id"
    JOIN OrderItems_2021 oi ON o."order_id" = oi."order_id"
    JOIN InventoryData_2021 i ON oi."inventory_item_id" = i."inventory_item_id"
    JOIN ProductsData p ON i."product_id" = p."product_id"
    GROUP BY 
        TO_CHAR(TO_TIMESTAMP(o."created_at" / 1000000), 'YYYY-MM'), 
        u."country", 
        i."product_department", 
        i."product_category"
    ORDER BY "month", "country", "product_department", "product_category"
)
SELECT *
FROM AggregatedData
LIMIT 1000;