WITH IncomeDifference AS (
    SELECT 
        t3."state_name", 
        AVG(t2."median_income" - t1."median_income") AS "avg_income_difference"
    FROM CENSUS_BUREAU_ACS_2.CENSUS_BUREAU_ACS.ZIP_CODES_2015_5YR t1
    JOIN CENSUS_BUREAU_ACS_2.CENSUS_BUREAU_ACS.ZIP_CODES_2018_5YR t2 
        ON t1."geo_id" = t2."geo_id"
    JOIN CENSUS_BUREAU_ACS_2.GEO_US_BOUNDARIES.ZIP_CODES t3 
        ON t1."geo_id" = t3."zip_code"
    GROUP BY t3."state_name"
    ORDER BY "avg_income_difference" DESC NULLS LAST
    LIMIT 5
), VulnerableEmployees AS (
    SELECT 
        t3."state_name", 
        AVG(
            t1."employed_wholesale_trade" * 0.38423645320197042 + 
            (t1."employed_agriculture_forestry_fishing_hunting_mining" + t1."employed_construction") * 0.48071410777129553 + 
            t1."employed_arts_entertainment_recreation_accommodation_food" * 0.89455676291236841 + 
            t1."employed_information" * 0.31315240083507306 + 
            t1."employed_retail_trade" * 0.51
        ) AS "avg_vulnerable_employees"
    FROM CENSUS_BUREAU_ACS_2.CENSUS_BUREAU_ACS.ZIP_CODES_2017_5YR t1
    JOIN CENSUS_BUREAU_ACS_2.GEO_US_BOUNDARIES.ZIP_CODES t3 
        ON t1."geo_id" = t3."zip_code"
    GROUP BY t3."state_name"
)
SELECT 
    i."state_name", 
    i."avg_income_difference", 
    v."avg_vulnerable_employees"
FROM IncomeDifference i
JOIN VulnerableEmployees v 
    ON i."state_name" = v."state_name"
ORDER BY i."avg_income_difference" DESC NULLS LAST
LIMIT 5;