WITH rfm_segments AS (
    -- Step 1: Calculate Recency, Frequency, and Monetary values for each customer
    SELECT 
        cus."customer_unique_id",
        
        -- Recency: Rank customers by the number of days since their most recent purchase
        NTILE(5) OVER (
            ORDER BY DATEDIFF('DAY', MAX(o."order_purchase_timestamp")::DATE, CURRENT_DATE)
        ) AS "recency_rank",
        
        -- Frequency: Rank customers based on their total number of orders
        NTILE(5) OVER (
            ORDER BY COUNT(DISTINCT o."order_id") DESC
        ) AS "frequency_rank",
        
        -- Monetary: Rank customers based on their total monetary value
        NTILE(5) OVER (
            ORDER BY SUM(oi."price" + oi."freight_value") DESC
        ) AS "monetary_rank"
        
    FROM E_COMMERCE.E_COMMERCE.CUSTOMERS AS cus
    JOIN E_COMMERCE.E_COMMERCE.ORDERS AS o
        ON cus."customer_id" = o."customer_id"
    JOIN E_COMMERCE.E_COMMERCE.ORDER_ITEMS AS oi
        ON o."order_id" = oi."order_id"
        
    WHERE o."order_status" = 'delivered' -- Only consider delivered orders
    
    GROUP BY cus."customer_unique_id"
),
rfm_classification AS (
    -- Step 2: Classify customers into RFM segments by concatenating Recency, Frequency, and Monetary rankings
    SELECT 
        rfm."customer_unique_id",
        CONCAT(
            rfm."recency_rank", 
            rfm."frequency_rank", 
            rfm."monetary_rank"
        ) AS "rfm_segment"
    FROM rfm_segments AS rfm
),
customer_sales AS (
    -- Step 3: Calculate Total Orders and Total Monetary Value for each customer
    SELECT 
        cus."customer_unique_id", 
        COUNT(DISTINCT o."order_id") AS "total_orders", 
        SUM(oi."price" + oi."freight_value") AS "total_monetary_value"
    FROM E_COMMERCE.E_COMMERCE.CUSTOMERS AS cus
    JOIN E_COMMERCE.E_COMMERCE.ORDERS AS o
        ON cus."customer_id" = o."customer_id"
    JOIN E_COMMERCE.E_COMMERCE.ORDER_ITEMS AS oi
        ON o."order_id" = oi."order_id"
        
    WHERE o."order_status" = 'delivered' -- Only consider delivered orders
    
    GROUP BY cus."customer_unique_id"
)
-- Step 4: Combine RFM Classification and Customer Sales to calculate average sales per order for each RFM segment
SELECT 
    rfm."rfm_segment", 
    AVG(cs."total_monetary_value" / cs."total_orders") AS "avg_sales_per_order"
FROM customer_sales AS cs
JOIN rfm_classification AS rfm
    ON cs."customer_unique_id" = rfm."customer_unique_id"
GROUP BY rfm."rfm_segment"
ORDER BY rfm."rfm_segment";