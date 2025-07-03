WITH RelevantCategories AS (
    SELECT 
        "category_name",
        AVG("monthly_percentage") AS "average_percentage",
        COUNT(DISTINCT "month") AS "months_count"
    FROM (
        SELECT 
            sub1."category_name",
            sub1."month",
            (sub1."total_volume" / sub2."total_monthly_volume") * 100 AS "monthly_percentage"
        FROM (
            SELECT 
                "category_name",
                DATE_TRUNC('month', "date") AS "month",
                SUM("volume_sold_liters") AS "total_volume"
            FROM "IOWA_LIQUOR_SALES"."IOWA_LIQUOR_SALES"."SALES"
            WHERE "date" >= '2022-01-01' AND "date" < DATE_TRUNC('month', CURRENT_DATE)
            GROUP BY "category_name", DATE_TRUNC('month', "date")
        ) sub1
        JOIN (
            SELECT 
                DATE_TRUNC('month', "date") AS "month",
                SUM("volume_sold_liters") AS "total_monthly_volume"
            FROM "IOWA_LIQUOR_SALES"."IOWA_LIQUOR_SALES"."SALES"
            WHERE "date" >= '2022-01-01' AND "date" < DATE_TRUNC('month', CURRENT_DATE)
            GROUP BY DATE_TRUNC('month', "date")
        ) sub2
        ON sub1."month" = sub2."month"
    )
    GROUP BY "category_name"
    HAVING AVG("monthly_percentage") >= 1 AND COUNT(DISTINCT "month") >= 24
),
CategoryPercentages AS (
    SELECT 
        sub1."category_name",
        sub1."month",
        (sub1."total_volume" / sub2."total_monthly_volume") * 100 AS "monthly_percentage"
    FROM (
        SELECT 
            "category_name",
            DATE_TRUNC('month', "date") AS "month",
            SUM("volume_sold_liters") AS "total_volume"
        FROM "IOWA_LIQUOR_SALES"."IOWA_LIQUOR_SALES"."SALES"
        WHERE "date" >= '2022-01-01' AND "date" < DATE_TRUNC('month', CURRENT_DATE)
        GROUP BY "category_name", DATE_TRUNC('month', "date")
    ) sub1
    JOIN (
        SELECT 
            DATE_TRUNC('month', "date") AS "month",
            SUM("volume_sold_liters") AS "total_monthly_volume"
        FROM "IOWA_LIQUOR_SALES"."IOWA_LIQUOR_SALES"."SALES"
        WHERE "date" >= '2022-01-01' AND "date" < DATE_TRUNC('month', CURRENT_DATE)
        GROUP BY DATE_TRUNC('month', "date")
    ) sub2
    ON sub1."month" = sub2."month"
    JOIN RelevantCategories
    ON sub1."category_name" = RelevantCategories."category_name"
),
CorrelationMatrix AS (
    SELECT 
        cat1."category_name" AS "category_x",
        cat2."category_name" AS "category_y",
        CORR(cat1."monthly_percentage", cat2."monthly_percentage") AS "correlation"
    FROM CategoryPercentages cat1
    JOIN CategoryPercentages cat2
    ON cat1."month" = cat2."month" AND cat1."category_name" < cat2."category_name"
    GROUP BY cat1."category_name", cat2."category_name"
),
LowestCorrelation AS (
    SELECT 
        "category_x",
        "category_y",
        "correlation"
    FROM CorrelationMatrix
    ORDER BY "correlation" ASC NULLS LAST
    LIMIT 1
)
SELECT 
    "category_x" AS "category_1",
    "category_y" AS "category_2",
    "correlation" AS "lowest_pearson_correlation"
FROM LowestCorrelation;