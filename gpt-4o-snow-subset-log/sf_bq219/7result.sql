WITH MonthlyCategoryPercentages AS (
    SELECT 
        DATE_TRUNC('month', "date") AS "month", 
        "category", 
        SUM("volume_sold_liters") / SUM(SUM("volume_sold_liters")) OVER(PARTITION BY DATE_TRUNC('month', "date")) AS "percentage"
    FROM "IOWA_LIQUOR_SALES"."IOWA_LIQUOR_SALES"."SALES"
    WHERE "date" >= '2022-01-01'
    GROUP BY DATE_TRUNC('month', "date"), "category"
),
QualifiedCategories AS (
    SELECT 
        "category", 
        AVG("percentage") AS "avg_percentage", 
        COUNT(DISTINCT "month") AS "total_months"
    FROM MonthlyCategoryPercentages
    GROUP BY "category"
    HAVING AVG("percentage") >= 0.01 AND COUNT(DISTINCT "month") >= 24
),
CategoryCorrelations AS (
    SELECT 
        c1."category" AS "category1", 
        c2."category" AS "category2", 
        CORR(c1."percentage", c2."percentage") AS "correlation"
    FROM MonthlyCategoryPercentages c1
    JOIN MonthlyCategoryPercentages c2
      ON c1."month" = c2."month" 
     AND c1."category" < c2."category"
    WHERE c1."category" IN (SELECT "category" FROM QualifiedCategories)
      AND c2."category" IN (SELECT "category" FROM QualifiedCategories)
    GROUP BY c1."category", c2."category"
),
LowestCorrelationCategories AS (
    SELECT 
        "category1", 
        "category2", 
        "correlation"
    FROM CategoryCorrelations
    ORDER BY "correlation" ASC NULLS LAST
    LIMIT 1
)
SELECT 
    lc."category1", 
    c1."category_name" AS "category1_name", 
    lc."category2", 
    c2."category_name" AS "category2_name", 
    lc."correlation"
FROM LowestCorrelationCategories lc
JOIN "IOWA_LIQUOR_SALES"."IOWA_LIQUOR_SALES"."SALES" c1
  ON lc."category1" = c1."category"
JOIN "IOWA_LIQUOR_SALES"."IOWA_LIQUOR_SALES"."SALES" c2
  ON lc."category2" = c2."category"
LIMIT 1;