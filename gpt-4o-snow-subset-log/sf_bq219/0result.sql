WITH Monthly_Sales AS (
    SELECT 
        DATE_TRUNC('month', "date") AS "month",
        "category_name",
        SUM("volume_sold_liters") AS "monthly_volume",
        (SUM("volume_sold_liters") / SUM(SUM("volume_sold_liters")) OVER (PARTITION BY DATE_TRUNC('month', "date"))) * 100 AS "percentage_of_monthly_volume"
    FROM "IOWA_LIQUOR_SALES"."IOWA_LIQUOR_SALES"."SALES"
    WHERE "date" >= '2022-01-01'
    GROUP BY DATE_TRUNC('month', "date"), "category_name"
),
Category_Averages AS (
    SELECT 
        "category_name",
        AVG("percentage_of_monthly_volume") AS "average_monthly_percentage",
        COUNT(DISTINCT "month") AS "month_count"
    FROM Monthly_Sales
    GROUP BY "category_name"
    HAVING AVG("percentage_of_monthly_volume") >= 1 AND COUNT(DISTINCT "month") >= 24
),
Filtered_Categories AS (
    SELECT 
        m."month",
        m."category_name",
        m."percentage_of_monthly_volume"
    FROM Monthly_Sales m
    INNER JOIN Category_Averages c
    ON m."category_name" = c."category_name"
),
Pairwise_Correlation AS (
    SELECT 
        c1."category_name" AS "category_name_1",
        c2."category_name" AS "category_name_2",
        CORR(c1."percentage_of_monthly_volume", c2."percentage_of_monthly_volume") AS "pearson_correlation"
    FROM Filtered_Categories c1
    JOIN Filtered_Categories c2
    ON c1."month" = c2."month" AND c1."category_name" < c2."category_name"
    GROUP BY c1."category_name", c2."category_name"
)
SELECT 
    "category_name_1",
    "category_name_2",
    "pearson_correlation"
FROM Pairwise_Correlation
ORDER BY "pearson_correlation" ASC NULLS LAST
LIMIT 1;