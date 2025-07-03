WITH category_percentages AS (
  SELECT 
    EXTRACT(YEAR FROM "date") AS "year", 
    EXTRACT(MONTH FROM "date") AS "month", 
    "category_name", 
    (SUM("volume_sold_liters") / SUM(SUM("volume_sold_liters")) 
      OVER (PARTITION BY EXTRACT(YEAR FROM "date"), EXTRACT(MONTH FROM "date"))) 
      AS "monthly_percentage"
  FROM "IOWA_LIQUOR_SALES"."IOWA_LIQUOR_SALES"."SALES"
  WHERE "date" >= '2022-01-01'
  GROUP BY EXTRACT(YEAR FROM "date"), EXTRACT(MONTH FROM "date"), "category_name"
), 
eligible_categories AS (
  SELECT 
    "category_name"
  FROM (
    SELECT 
      "category_name", 
      AVG("monthly_percentage") AS "average_monthly_percentage",
      COUNT(DISTINCT CONCAT("year", '-', "month")) AS "months_count"
    FROM category_percentages
    GROUP BY "category_name"
  )
  WHERE "average_monthly_percentage" >= 0.01
    AND "months_count" >= 24
), 
paired_category_correlations AS (
  SELECT 
    p1."category_name" AS "category_1", 
    p2."category_name" AS "category_2", 
    CORR(p1."monthly_percentage", p2."monthly_percentage") AS "pearson_correlation"
  FROM category_percentages p1
  JOIN category_percentages p2
    ON p1."year" = p2."year"
    AND p1."month" = p2."month"
    AND p1."category_name" < p2."category_name"
  WHERE p1."category_name" IN (SELECT "category_name" FROM eligible_categories)
    AND p2."category_name" IN (SELECT "category_name" FROM eligible_categories)
  GROUP BY p1."category_name", p2."category_name"
)
SELECT 
  "category_1", 
  "category_2", 
  "pearson_correlation"
FROM paired_category_correlations
ORDER BY "pearson_correlation" ASC
LIMIT 1;