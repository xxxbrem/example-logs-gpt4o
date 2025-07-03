WITH filtered_data AS (
    -- Step 1: Filter data for the desired date range and calculate monthly sales percentages
    SELECT 
        DATE_TRUNC('MONTH', "date") AS "sales_month",
        "category_name",
        SUM("volume_sold_liters") AS "category_volume",
        SUM(SUM("volume_sold_liters")) OVER (PARTITION BY DATE_TRUNC('MONTH', "date")) AS "monthly_total_volume",
        (SUM("volume_sold_liters") / SUM(SUM("volume_sold_liters")) OVER (PARTITION BY DATE_TRUNC('MONTH', "date"))) * 100 AS "monthly_percentage"
    FROM 
        "IOWA_LIQUOR_SALES"."IOWA_LIQUOR_SALES"."SALES"
    WHERE 
        "date" >= '2022-01-01' 
        AND "date" < DATE_TRUNC('MONTH', CURRENT_DATE) -- Exclude the current partial month
    GROUP BY 
        DATE_TRUNC('MONTH', "date"), "category_name"
),
qualifying_categories AS (
    -- Step 2: Filter categories that contribute at least 1% to monthly sales over at least 24 months
    SELECT 
        "category_name"
    FROM (
        SELECT 
            "category_name",
            COUNT(DISTINCT "sales_month") AS "num_months",
            AVG("monthly_percentage") AS "avg_monthly_percentage"
        FROM 
            filtered_data
        WHERE 
            "monthly_percentage" >= 1
        GROUP BY 
            "category_name"
    )
    WHERE 
        "num_months" >= 24
),
category_percentages AS (
    -- Step 3: Get the monthly percentages for the qualifying categories
    SELECT 
        f."sales_month",
        f."category_name",
        f."monthly_percentage"
    FROM 
        filtered_data f
    JOIN 
        qualifying_categories q
    ON 
        f."category_name" = q."category_name"
),
category_pairs AS (
    -- Step 4: Calculate pairwise Pearson correlation coefficients
    SELECT 
        p1."category_name" AS "category_1", 
        p2."category_name" AS "category_2", 
        CORR(p1."monthly_percentage", p2."monthly_percentage") AS "correlation"
    FROM 
        category_percentages p1
    JOIN 
        category_percentages p2
    ON 
        p1."sales_month" = p2."sales_month" AND p1."category_name" < p2."category_name"
    GROUP BY 
        p1."category_name", p2."category_name"
)
-- Step 5: Retrieve the pair with the lowest correlation
SELECT 
    "category_1", 
    "category_2", 
    "correlation"
FROM 
    category_pairs
ORDER BY 
    "correlation" ASC NULLS LAST
LIMIT 1;