WITH income_differences AS (
    SELECT 
        g."state_code",
        g."state_name",
        AVG(z18."median_income" - z15."median_income") AS "avg_income_difference"
    FROM CENSUS_BUREAU_ACS_2.CENSUS_BUREAU_ACS.ZIP_CODES_2015_5YR z15
    JOIN CENSUS_BUREAU_ACS_2.CENSUS_BUREAU_ACS.ZIP_CODES_2018_5YR z18
        ON z15."geo_id" = z18."geo_id"
    JOIN CENSUS_BUREAU_ACS_2.GEO_US_BOUNDARIES.ZIP_CODES g
        ON g."zip_code" = z15."geo_id"
    WHERE z15."median_income" IS NOT NULL AND z18."median_income" IS NOT NULL
    GROUP BY g."state_code", g."state_name"
    ORDER BY "avg_income_difference" DESC NULLS LAST
    LIMIT 5
),
vulnerable_employees AS (
    SELECT 
        g."state_code",
        g."state_name",
        AVG(
            0.38423645320197042 * z17."employed_wholesale_trade" +
            0.48071410777129553 * z17."employed_construction" +
            0.89455676291236841 * z17."employed_arts_entertainment_recreation_accommodation_food" +
            0.31315240083507306 * z17."employed_information" +
            0.51 * z17."employed_retail_trade"
        ) AS "avg_vulnerable_employees"
    FROM CENSUS_BUREAU_ACS_2.CENSUS_BUREAU_ACS.ZIP_CODES_2017_5YR z17
    JOIN CENSUS_BUREAU_ACS_2.GEO_US_BOUNDARIES.ZIP_CODES g
        ON g."zip_code" = z17."geo_id"
    GROUP BY g."state_code", g."state_name"
),
result AS (
    SELECT 
        i."state_name",
        i."state_code",
        i."avg_income_difference",
        v."avg_vulnerable_employees"
    FROM income_differences i
    JOIN vulnerable_employees v
        ON i."state_code" = v."state_code"
)
SELECT 
    "state_name",
    "state_code",
    "avg_income_difference",
    "avg_vulnerable_employees"
FROM result
ORDER BY "avg_income_difference" DESC NULLS LAST;