WITH DeliveredOrders AS (
    -- Step 1: Filter 'delivered' orders and their purchase/delivered timestamps
    SELECT DISTINCT 
        o."order_id", 
        o."customer_id", 
        c."customer_unique_id", 
        o."order_purchase_timestamp", 
        o."order_delivered_customer_date"
    FROM E_COMMERCE.E_COMMERCE.ORDERS o
    JOIN E_COMMERCE.E_COMMERCE.CUSTOMERS c
        ON o."customer_id" = c."customer_id"
    WHERE o."order_status" = 'delivered'
),
OrderSpending AS (
    -- Step 2: Calculate total spend per order
    SELECT DISTINCT 
        "order_id", 
        SUM("price" + "freight_value") AS "total_spent"
    FROM E_COMMERCE.E_COMMERCE.ORDER_ITEMS
    GROUP BY "order_id"
),
CustomerRFM AS (
    -- Step 3: Combine orders and calculate Recency, Frequency, and Monetary per customer
    SELECT 
        d."customer_unique_id",
        MAX(d."order_delivered_customer_date") AS "last_order_date", -- Recency
        COUNT(d."order_id") AS "order_frequency", -- Frequency
        SUM(o."total_spent") AS "total_monetary" -- Monetary
    FROM DeliveredOrders d
    JOIN OrderSpending o
        ON d."order_id" = o."order_id"
    GROUP BY d."customer_unique_id"
),
RFMScored AS (
    -- Step 4: Assign RFM scores using quantiles
    SELECT 
        "customer_unique_id", 
        "last_order_date",
        "order_frequency",
        "total_monetary",
        NTILE(5) OVER (ORDER BY "last_order_date" DESC NULLS LAST) AS "recency_score",
        NTILE(5) OVER (ORDER BY "order_frequency" DESC NULLS LAST) AS "frequency_score",
        NTILE(5) OVER (ORDER BY "total_monetary" DESC NULLS LAST) AS "monetary_score"
    FROM CustomerRFM
),
RFMSegment AS (
    -- Step 5: Categorize into RFM segments
    SELECT 
        "customer_unique_id", 
        "recency_score", 
        "frequency_score", 
        "monetary_score",
        CONCAT("recency_score", "frequency_score", "monetary_score") AS "rfm_segment"
    FROM RFMScored
),
AverageSales AS (
    -- Step 6: Compute average sales per order
    SELECT 
        r."rfm_segment",
        c."customer_unique_id",
        c."total_monetary" / NULLIF(c."order_frequency", 0) AS "average_sales_per_order" -- Avoid division by zero
    FROM CustomerRFM c
    JOIN RFMSegment r
        ON c."customer_unique_id" = r."customer_unique_id"
)
-- Step 7: Calculate the average sales per order for each RFM segment
SELECT 
    "rfm_segment",
    AVG("average_sales_per_order") AS "avg_sales_per_order_per_segment"
FROM AverageSales
GROUP BY "rfm_segment"
ORDER BY "avg_sales_per_order_per_segment" DESC;