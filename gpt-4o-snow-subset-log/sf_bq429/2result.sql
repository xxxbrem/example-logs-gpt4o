WITH IncomeDifference AS (
    SELECT 
        zb."state_code", 
        AVG(inc_2018."median_income") - AVG(inc_2015."median_income") AS "median_income_difference"
    FROM 
        CENSUS_BUREAU_ACS_2.GEO_US_BOUNDARIES.ZIP_CODES zb
    JOIN 
        CENSUS_BUREAU_ACS_2.CENSUS_BUREAU_ACS.ZIP_CODES_2015_5YR inc_2015 
    ON 
        zb."zip_code" = inc_2015."geo_id"
    JOIN 
        CENSUS_BUREAU_ACS_2.CENSUS_BUREAU_ACS.ZIP_CODES_2018_5YR inc_2018 
    ON 
        zb."zip_code" = inc_2018."geo_id"
    WHERE 
        inc_2015."median_income" IS NOT NULL AND inc_2018."median_income" IS NOT NULL
    GROUP BY 
        zb."state_code"
    ORDER BY 
        "median_income_difference" DESC NULLS LAST 
    LIMIT 5
), 
VulnerableEmployment AS (
    SELECT 
        zb."state_code",
        SUM(zc."employed_wholesale_trade") * 0.38423645320197042 + 
        (SUM(zc."employed_agriculture_forestry_fishing_hunting_mining") + SUM(zc."employed_construction")) * 0.48071410777129553 +
        SUM(zc."employed_arts_entertainment_recreation_accommodation_food") * 0.89455676291236841 +
        SUM(zc."employed_information") * 0.31315240083507306 +
        SUM(zc."employed_retail_trade") * 0.51 AS "vulnerable_employment_average"
    FROM 
        CENSUS_BUREAU_ACS_2.GEO_US_BOUNDARIES.ZIP_CODES zb
    JOIN 
        CENSUS_BUREAU_ACS_2.CENSUS_BUREAU_ACS.ZIP_CODES_2017_5YR zc 
    ON 
        zb."zip_code" = zc."geo_id"
    WHERE 
        zc."employed_wholesale_trade" IS NOT NULL AND 
        zc."employed_agriculture_forestry_fishing_hunting_mining" IS NOT NULL AND
        zc."employed_construction" IS NOT NULL AND
        zc."employed_arts_entertainment_recreation_accommodation_food" IS NOT NULL AND
        zc."employed_information" IS NOT NULL AND
        zc."employed_retail_trade" IS NOT NULL
    GROUP BY 
        zb."state_code"
)
SELECT 
    id."state_code", 
    id."median_income_difference", 
    ve."vulnerable_employment_average"
FROM 
    IncomeDifference id
JOIN 
    VulnerableEmployment ve 
ON 
    id."state_code" = ve."state_code"
ORDER BY 
    id."median_income_difference" DESC NULLS LAST
LIMIT 5;