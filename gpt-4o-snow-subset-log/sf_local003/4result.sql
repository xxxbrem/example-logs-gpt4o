WITH recency AS (
    -- Calculate recency score based on the latest delivery timestamp
    SELECT 
        c."customer_unique_id",
        DATEDIFF(
            DAY, 
            MAX(TRY_TO_DATE(LEFT(o."order_delivered_customer_date", 10), 'YYYY-MM-DD')), 
            CURRENT_DATE
        ) AS "recency_days"
    FROM E_COMMERCE.E_COMMERCE.ORDERS o
    JOIN E_COMMERCE.E_COMMERCE.CUSTOMERS c 
      ON o."customer_id" = c."customer_id"
    WHERE o."order_status" = 'delivered' 
      AND o."order_delivered_customer_date" IS NOT NULL
    GROUP BY c."customer_unique_id"
),
recency_score AS (
    -- Assign recency scores based on quintiles
    SELECT 
        "customer_unique_id",
        NTILE(5) OVER (ORDER BY "recency_days" ASC) AS "recency_score"
    FROM recency
),
frequency AS (
    -- Calculate order frequency for each customer
    SELECT 
        c."customer_unique_id",
        COUNT(o."order_id") AS "order_frequency"
    FROM E_COMMERCE.E_COMMERCE.ORDERS o
    JOIN E_COMMERCE.E_COMMERCE.CUSTOMERS c
      ON o."customer_id" = c."customer_id"
    WHERE o."order_status" = 'delivered'
    GROUP BY c."customer_unique_id"
),
frequency_score AS (
    -- Assign frequency scores based on quintiles
    SELECT 
        "customer_unique_id",
        NTILE(5) OVER (ORDER BY "order_frequency" DESC) AS "frequency_score"
    FROM frequency
),
monetary AS (
    -- Calculate average sales per order for each customer
    SELECT 
        c."customer_unique_id",
        SUM(p."payment_value") / COUNT(DISTINCT o."order_id") AS "avg_sales_per_order"
    FROM E_COMMERCE.E_COMMERCE.ORDERS o
    JOIN E_COMMERCE.E_COMMERCE.ORDER_PAYMENTS p
      ON o."order_id" = p."order_id"
    JOIN E_COMMERCE.E_COMMERCE.CUSTOMERS c
      ON o."customer_id" = c."customer_id"
    WHERE o."order_status" = 'delivered' 
      AND p."payment_value" IS NOT NULL
    GROUP BY c."customer_unique_id"
),
monetary_score AS (
    -- Assign monetary scores based on quintiles
    SELECT 
        "customer_unique_id",
        NTILE(5) OVER (ORDER BY "avg_sales_per_order" DESC) AS "monetary_score"
    FROM monetary
),
rfm_combined AS (
    -- Combine recency, frequency, and monetary scores
    SELECT 
        r."customer_unique_id",
        r."recency_score",
        f."frequency_score",
        m."monetary_score",
        CONCAT(r."recency_score", f."frequency_score", m."monetary_score") AS "rfm_segment",
        mo."avg_sales_per_order"
    FROM recency_score r
    JOIN frequency_score f
      ON r."customer_unique_id" = f."customer_unique_id"
    JOIN monetary_score m
      ON r."customer_unique_id" = m."customer_unique_id"
    JOIN monetary mo
      ON r."customer_unique_id" = mo."customer_unique_id"
)
-- Calculate average sales per order for each RFM segment
SELECT 
    "rfm_segment",
    COUNT("customer_unique_id") AS "customer_count",
    ROUND(AVG("avg_sales_per_order"), 4) AS "average_sales_per_order"
FROM rfm_combined
GROUP BY "rfm_segment"
ORDER BY "average_sales_per_order" DESC NULLS LAST;