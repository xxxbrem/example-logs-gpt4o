WITH MedianIncomeDifference AS (
    SELECT 
        f."state", 
        AVG(t18."median_income" - t15."median_income") AS "avg_median_income_diff"
    FROM 
        CENSUS_BUREAU_ACS_2.CENSUS_BUREAU_ACS.ZIP_CODES_2015_5YR t15
    JOIN 
        CENSUS_BUREAU_ACS_2.CENSUS_BUREAU_ACS.ZIP_CODES_2018_5YR t18
        ON t15."geo_id" = t18."geo_id"
    JOIN 
        CENSUS_BUREAU_ACS_2.GEO_US_BOUNDARIES.ZIP_CODES z
        ON t15."geo_id" = z."zip_code"
    JOIN 
        CENSUS_BUREAU_ACS_2.CYCLISTIC.STATE_FIPS f
        ON z."state_code" = f."postal_code"
    GROUP BY 
        f."state"
    ORDER BY 
        "avg_median_income_diff" DESC NULLS LAST
    LIMIT 5
),
VulnerableEmployment AS (
    SELECT 
        f."state",
        AVG(v."employed_wholesale_trade" * 0.38423645320197042 +
            (v."employed_agriculture_forestry_fishing_hunting_mining" + v."employed_construction") * 0.48071410777129553 +
            v."employed_arts_entertainment_recreation_accommodation_food" * 0.89455676291236841 +
            v."employed_information" * 0.31315240083507306 +
            v."employed_retail_trade" * 0.51) AS "avg_vulnerable_employment"
    FROM 
        CENSUS_BUREAU_ACS_2.CENSUS_BUREAU_ACS.ZIP_CODES_2017_5YR v
    JOIN 
        CENSUS_BUREAU_ACS_2.GEO_US_BOUNDARIES.ZIP_CODES z
        ON v."geo_id" = z."zip_code"
    JOIN 
        CENSUS_BUREAU_ACS_2.CYCLISTIC.STATE_FIPS f
        ON z."state_code" = f."postal_code"
    GROUP BY 
        f."state"
)
SELECT 
    m."state",
    m."avg_median_income_diff",
    v."avg_vulnerable_employment"
FROM 
    MedianIncomeDifference m
JOIN 
    VulnerableEmployment v
    ON m."state" = v."state"
ORDER BY 
    m."avg_median_income_diff" DESC NULLS LAST;