WITH Monthly_Percentages AS (
    SELECT 
        EXTRACT(YEAR FROM "date") AS "year", 
        EXTRACT(MONTH FROM "date") AS "month", 
        "category_name", 
        SUM("volume_sold_liters") / SUM(SUM("volume_sold_liters")) OVER (PARTITION BY EXTRACT(YEAR FROM "date"), EXTRACT(MONTH FROM "date")) * 100 AS "monthly_percentage"
    FROM "IOWA_LIQUOR_SALES"."IOWA_LIQUOR_SALES"."SALES"
    WHERE "date" >= '2022-01-01'
    GROUP BY "year", "month", "category_name"
),
Filtered_Categories AS (
    SELECT 
        "category_name",
        AVG("monthly_percentage") AS "avg_monthly_percentage",
        COUNT(DISTINCT "year" || '-' || "month") AS "months_with_data"
    FROM Monthly_Percentages
    GROUP BY "category_name"
    HAVING AVG("monthly_percentage") >= 1 AND COUNT(DISTINCT "year" || '-' || "month") >= 24
),
Category_Percentages AS (
    SELECT 
        mp."category_name", 
        mp."year", 
        mp."month", 
        mp."monthly_percentage"
    FROM Monthly_Percentages mp
    JOIN Filtered_Categories fc
    ON mp."category_name" = fc."category_name"
),
Category_Pairs AS (
    SELECT 
        c1."category_name" AS "category_1", 
        c2."category_name" AS "category_2", 
        CORR(c1."monthly_percentage", c2."monthly_percentage") AS "pearson_corr"
    FROM Category_Percentages c1
    JOIN Category_Percentages c2
    ON c1."year" = c2."year" AND c1."month" = c2."month" AND c1."category_name" < c2."category_name"
    GROUP BY c1."category_name", c2."category_name"
),
Lowest_Correlation AS (
    SELECT *
    FROM Category_Pairs
    ORDER BY "pearson_corr" ASC NULLS LAST
    LIMIT 1
)
SELECT 
    "category_1", 
    "category_2", 
    "pearson_corr"
FROM Lowest_Correlation;