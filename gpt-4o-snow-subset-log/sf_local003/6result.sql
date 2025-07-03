WITH RFM_DATA AS (
    -- Step 1: Calculate Recency (days since last purchase) for each customer
    SELECT c."customer_unique_id",
           DATEDIFF(DAY, MAX(o."order_purchase_timestamp")::DATE, CURRENT_DATE) AS "recency",
           COUNT(DISTINCT o."order_id") AS "order_frequency",
           SUM(oi."price" + oi."freight_value") AS "monetary_value"
    FROM E_COMMERCE.E_COMMERCE.CUSTOMERS c
    JOIN E_COMMERCE.E_COMMERCE.ORDERS o 
    ON c."customer_id" = o."customer_id"
    JOIN E_COMMERCE.E_COMMERCE.ORDER_ITEMS oi 
    ON o."order_id" = oi."order_id"
    WHERE o."order_status" ILIKE '%delivered%'
    GROUP BY c."customer_unique_id"
),
RFM_SCORES AS (
    -- Step 2: Assign R, F, and M scores using NTILE(5) to rank customers into quintiles
    SELECT rfm."customer_unique_id",
           NTILE(5) OVER (ORDER BY rfm."recency" ASC) AS "recency_score",
           NTILE(5) OVER (ORDER BY rfm."order_frequency" DESC) AS "frequency_score",
           NTILE(5) OVER (ORDER BY rfm."monetary_value" DESC) AS "monetary_score"
    FROM RFM_DATA rfm
),
RFM_SEGMENTS AS (
    -- Step 3: Combine RFM scores to form segments and calculate average sales per order
    SELECT rfm."customer_unique_id",
           CONCAT(rfm."recency_score", rfm."frequency_score", rfm."monetary_score") AS "rfm_segment",
           rfm_data."monetary_value" / rfm_data."order_frequency" AS "avg_sales_per_order"
    FROM RFM_SCORES rfm
    JOIN RFM_DATA rfm_data
    ON rfm."customer_unique_id" = rfm_data."customer_unique_id"
),
SEGMENT_SALES AS (
    -- Step 4: Aggregate average sales per order for each RFM segment
    SELECT "rfm_segment",
           AVG("avg_sales_per_order") AS "avg_sales_per_segment"
    FROM RFM_SEGMENTS
    GROUP BY "rfm_segment"
)
-- Step 5: Display results ordered by average sales per segment (highest to lowest)
SELECT "rfm_segment", "avg_sales_per_segment"
FROM SEGMENT_SALES
ORDER BY "avg_sales_per_segment" DESC NULLS LAST
LIMIT 20;