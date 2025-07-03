WITH RFM_CALCULATION AS (
    -- Step 1: Calculate Recency (days since the customer's most recent 'delivered' order), Frequency (total orders), and Monetary (total spend)
    SELECT 
        c."customer_unique_id",
        DATEDIFF(DAY, MAX(TRY_TO_TIMESTAMP(o."order_delivered_customer_date", 'YYYY-MM-DD HH24:MI:SS')), CURRENT_DATE) AS "recency",
        COUNT(o."order_id") AS "frequency",
        SUM(oi."price") AS "monetary",
        SUM(oi."price") / COUNT(o."order_id") AS "avg_sales_per_order"
    FROM E_COMMERCE.E_COMMERCE.CUSTOMERS c
    JOIN E_COMMERCE.E_COMMERCE.ORDERS o ON c."customer_id" = o."customer_id"
    JOIN E_COMMERCE.E_COMMERCE.ORDER_ITEMS oi ON o."order_id" = oi."order_id"
    WHERE o."order_status" = 'delivered'
    GROUP BY c."customer_unique_id"
),
RFM_SEGMENTS AS (
    -- Step 2: Assign RFM segments based on defined conditions
    SELECT 
        rfm."customer_unique_id",
        rfm."recency",
        rfm."frequency",
        rfm."monetary",
        rfm."avg_sales_per_order",
        CASE 
            WHEN rfm."recency" <= 30 AND rfm."frequency" >= 5 AND rfm."monetary" > 500 THEN 'Champions'
            WHEN rfm."recency" > 30 AND rfm."recency" <= 90 AND rfm."frequency" >= 3 THEN 'Loyal Customers'
            WHEN rfm."recency" > 90 AND rfm."monetary" <= 200 THEN 'Hibernating'
            ELSE 'Others'
        END AS "rfm_segment"
    FROM RFM_CALCULATION rfm
)
-- Step 3: Calculate average sales per order across each RFM segment
SELECT 
    rfm."rfm_segment",
    COUNT(rfm."customer_unique_id") AS "number_of_customers",
    AVG(rfm."avg_sales_per_order") AS "avg_sales_per_order"
FROM RFM_SEGMENTS rfm
GROUP BY rfm."rfm_segment"
ORDER BY "avg_sales_per_order" DESC NULLS LAST;