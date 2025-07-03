WITH customer_metrics AS (
    -- Calculate Recency, Frequency, and Monetary values for each customer unique ID
    SELECT 
        c."customer_unique_id", 
        MAX(o."order_purchase_timestamp") AS "latest_purchase_date",                     -- Latest order for Recency
        COUNT(DISTINCT o."order_id") AS "total_orders",                                  -- Total number of delivered orders for Frequency
        SUM(i."price") AS "total_spend",                                                -- Total spend for the Monetary value
        SUM(i."price") / COUNT(DISTINCT o."order_id") AS "average_sales_per_order"       -- Calculate average sales per order
    FROM 
        E_COMMERCE.E_COMMERCE.CUSTOMERS c
    JOIN 
        E_COMMERCE.E_COMMERCE.ORDERS o 
        ON c."customer_id" = o."customer_id"                                            -- Join orders with customers
    JOIN 
        E_COMMERCE.E_COMMERCE.ORDER_ITEMS i 
        ON o."order_id" = i."order_id"                                                  -- Join order items with orders
    WHERE 
        o."order_status" = 'delivered'                                                  -- Only include 'delivered' orders
    GROUP BY 
        c."customer_unique_id"
),
customer_rfm AS (
    -- Assign R, F, and M scores using NTILE
    SELECT 
        "customer_unique_id",
        NTILE(5) OVER (ORDER BY "latest_purchase_date" DESC NULLS LAST) AS "recency_score",  -- Group customers into 5 Recency percentiles
        NTILE(5) OVER (ORDER BY "total_orders" DESC NULLS LAST) AS "frequency_score",       -- Group customers into 5 Frequency percentiles
        NTILE(5) OVER (ORDER BY "total_spend" DESC NULLS LAST) AS "monetary_score",         -- Group customers into 5 Monetary percentiles
        "average_sales_per_order"                                                          -- Keep calculated average sales
    FROM 
        customer_metrics
)
-- Combine scores into RFM segments and calculate average sales per order per segment
SELECT 
    CONCAT("recency_score", "frequency_score", "monetary_score") AS "rfm_segment",         -- Concatenate RFM scores into RFM segment string
    AVG("average_sales_per_order") AS "avg_sales_per_order"                               -- Calculate the average sales per order for each segment
FROM 
    customer_rfm
GROUP BY 
    CONCAT("recency_score", "frequency_score", "monetary_score")                          -- Group by RFM segments
ORDER BY 
    "avg_sales_per_order" DESC NULLS LAST                                                 -- Order by average sales per order in descending order
LIMIT 20;