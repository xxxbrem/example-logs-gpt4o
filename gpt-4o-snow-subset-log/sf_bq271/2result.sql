WITH Filtered_Orders AS (
    SELECT 
        o."order_id",
        o."user_id",
        o."created_at" AS "order_created_at"
    FROM 
        THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.ORDERS o
    JOIN 
        THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.USERS u
        ON o."user_id" = u."id"
    WHERE 
        o."created_at" BETWEEN 1609459200000000 AND 1640995200000000 -- Orders placed in 2021
        AND u."created_at" BETWEEN 1609459200000000 AND 1640995200000000 -- Users registered in 2021
),
Filtered_Inventory_Items AS (
    SELECT 
        ii."id" AS "inventory_item_id",
        ii."product_id",
        ii."created_at" AS "inventory_item_created_at"
    FROM 
        THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.INVENTORY_ITEMS ii
    WHERE 
        ii."created_at" BETWEEN 1609459200000000 AND 1640995200000000 -- Inventory items created in 2021
),
Order_Details AS (
    SELECT
        fo."order_id",
        fo."user_id",
        fo."order_created_at",
        oi."inventory_item_id",
        oi."sale_price",
        oi."status"
    FROM
        Filtered_Orders fo
    JOIN
        THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.ORDER_ITEMS oi
        ON fo."order_id" = oi."order_id"
    JOIN
        Filtered_Inventory_Items fii
        ON oi."inventory_item_id" = fii."inventory_item_id"
),
Product_Details AS (
    SELECT
        od."order_id",
        od."user_id",
        od."order_created_at",
        u."country",
        p."department" AS "product_department",
        p."category" AS "product_category",
        p."retail_price",
        p."cost"
    FROM
        Order_Details od
    JOIN
        THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.USERS u
        ON od."user_id" = u."id"
    JOIN
        THELOOK_ECOMMERCE.THELOOK_ECOMMERCE.PRODUCTS p
        ON od."inventory_item_id" = p."id"
),
Monthly_Report AS (
    SELECT
        DATE_TRUNC('MONTH', TO_TIMESTAMP(pd."order_created_at" / 1000000)) AS "order_month",
        pd."country",
        pd."product_department",
        pd."product_category",
        COUNT(DISTINCT pd."order_id") AS "number_of_orders",
        COUNT(DISTINCT pd."user_id") AS "unique_purchasers",
        SUM(pd."retail_price" - pd."cost") AS "total_profit"
    FROM
        Product_Details pd
    GROUP BY
        DATE_TRUNC('MONTH', TO_TIMESTAMP(pd."order_created_at" / 1000000)),
        pd."country",
        pd."product_department",
        pd."product_category"
)
SELECT
    "order_month",
    "country",
    "product_department",
    "product_category",
    "number_of_orders",
    "unique_purchasers",
    "total_profit"
FROM
    Monthly_Report
ORDER BY
    "order_month",
    "country",
    "product_department",
    "product_category";