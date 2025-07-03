WITH CategoryMonthlyPercentage AS (
    -- Calculate monthly percentage contribution of each liquor category
    SELECT a."category_name", a."month",
           (a."monthly_volume" / b."total_monthly_volume") * 100 AS "monthly_percentage"
    FROM 
        (SELECT DATE_TRUNC('MONTH', "date") AS "month", "category_name", 
                SUM("volume_sold_liters") AS "monthly_volume"
         FROM "IOWA_LIQUOR_SALES"."IOWA_LIQUOR_SALES"."SALES"
         WHERE "date" >= '2022-01-01'
         GROUP BY "month", "category_name") a
    JOIN 
        (SELECT DATE_TRUNC('MONTH', "date") AS "month", 
                SUM("volume_sold_liters") AS "total_monthly_volume"
         FROM "IOWA_LIQUOR_SALES"."IOWA_LIQUOR_SALES"."SALES"
         WHERE "date" >= '2022-01-01'
         GROUP BY "month") b
    ON a."month" = b."month"
),
FilteredCategories AS (
    -- Filter categories contributing at least 1% to monthly sales across at least 24 months
    SELECT "category_name"
    FROM (
        SELECT "category_name", COUNT(DISTINCT "month") AS "months_with_data", 
               AVG("monthly_percentage") AS "avg_monthly_percentage"
        FROM CategoryMonthlyPercentage
        WHERE "monthly_percentage" >= 1
        GROUP BY "category_name"
    )
    WHERE "months_with_data" >= 24
),
PairedCategories AS (
    -- Pair all filtered categories and calculate Pearson correlation for each pair
    SELECT c1."category_name" AS "category_1", 
           c2."category_name" AS "category_2",
           CORR(c1."monthly_percentage", c2."monthly_percentage") AS "pearson_correlation"
    FROM CategoryMonthlyPercentage c1
    JOIN CategoryMonthlyPercentage c2
    ON c1."month" = c2."month" 
       AND c1."category_name" < c2."category_name"
    WHERE c1."category_name" IN (SELECT "category_name" FROM FilteredCategories)
      AND c2."category_name" IN (SELECT "category_name" FROM FilteredCategories)
    GROUP BY c1."category_name", c2."category_name"
)
-- Select the pair of categories with the lowest Pearson correlation
SELECT "category_1", "category_2", "pearson_correlation"
FROM PairedCategories
ORDER BY "pearson_correlation" ASC
LIMIT 1;