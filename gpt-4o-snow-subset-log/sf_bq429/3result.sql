WITH income_difference AS (
    SELECT 
        z."state_name",
        z."state_code",
        AVG(t2."median_income" - t1."median_income") AS "average_median_income_difference"
    FROM CENSUS_BUREAU_ACS_2.GEO_US_BOUNDARIES.ZIP_CODES z
    LEFT JOIN CENSUS_BUREAU_ACS_2.CENSUS_BUREAU_ACS.ZIP_CODES_2015_5YR t1 
    ON z."zip_code" = t1."geo_id"
    LEFT JOIN CENSUS_BUREAU_ACS_2.CENSUS_BUREAU_ACS.ZIP_CODES_2018_5YR t2 
    ON z."zip_code" = t2."geo_id"
    GROUP BY z."state_name", z."state_code"
    ORDER BY AVG(t2."median_income" - t1."median_income") DESC NULLS LAST
    LIMIT 5
),
vulnerable_employees AS (
    SELECT 
        z."state_name",
        z."state_code",
        AVG(
            (t3."employed_wholesale_trade" * 0.38423645320197042) +
            ((t3."employed_agriculture_forestry_fishing_hunting_mining" + t3."employed_construction") * 0.48071410777129553) +
            (t3."employed_arts_entertainment_recreation_accommodation_food" * 0.89455676291236841) +
            (t3."employed_information" * 0.31315240083507306) +
            (t3."employed_retail_trade" * 0.51)
        ) AS "average_vulnerable_employees"
    FROM CENSUS_BUREAU_ACS_2.GEO_US_BOUNDARIES.ZIP_CODES z
    LEFT JOIN CENSUS_BUREAU_ACS_2.CENSUS_BUREAU_ACS.ZIP_CODES_2017_5YR t3
    ON z."zip_code" = t3."geo_id"
    GROUP BY z."state_name", z."state_code"
)
SELECT 
    id."state_name",
    id."state_code",
    id."average_median_income_difference",
    ve."average_vulnerable_employees"
FROM income_difference id
LEFT JOIN vulnerable_employees ve
ON id."state_name" = ve."state_name" AND id."state_code" = ve."state_code"
ORDER BY id."average_median_income_difference" DESC NULLS LAST;