WITH monthly_percentages AS (
    SELECT 
        DATE_TRUNC('month', "date") AS "month",
        "category",
        SUM("volume_sold_liters") /
        SUM(SUM("volume_sold_liters")) OVER (PARTITION BY DATE_TRUNC('month', "date")) * 100 AS "monthly_percentage"
    FROM "IOWA_LIQUOR_SALES"."IOWA_LIQUOR_SALES"."SALES"
    WHERE "date" >= '2022-01-01'
    GROUP BY DATE_TRUNC('month', "date"), "category"
),
filtered_categories AS (
    SELECT 
        "category",
        AVG("monthly_percentage") AS "avg_percentage",
        COUNT(DISTINCT "month") AS "months_count"
    FROM monthly_percentages
    GROUP BY "category"
    HAVING AVG("monthly_percentage") >= 1 AND COUNT(DISTINCT "month") >= 24
),
category_time_series AS (
    SELECT 
        mp."category",
        mp."month",
        mp."monthly_percentage"
    FROM monthly_percentages mp
    JOIN filtered_categories fc
    ON mp."category" = fc."category"
),
correlations AS (
    SELECT 
        c1."category" AS "category_1",
        c2."category" AS "category_2",
        CORR(c1."monthly_percentage", c2."monthly_percentage") AS "pearson_correlation"
    FROM category_time_series c1
    JOIN category_time_series c2
    ON c1."month" = c2."month" AND c1."category" < c2."category"
    GROUP BY c1."category", c2."category"
    ORDER BY "pearson_correlation" ASC NULLS LAST
    LIMIT 1
)
SELECT 
    corr."category_1",
    corr."category_2",
    cat1."category_name" AS "category_1_name",
    cat2."category_name" AS "category_2_name",
    corr."pearson_correlation"
FROM correlations corr
LEFT JOIN "IOWA_LIQUOR_SALES"."IOWA_LIQUOR_SALES"."SALES" cat1
ON corr."category_1" = cat1."category"
LEFT JOIN "IOWA_LIQUOR_SALES"."IOWA_LIQUOR_SALES"."SALES" cat2
ON corr."category_2" = cat2."category"
LIMIT 1;