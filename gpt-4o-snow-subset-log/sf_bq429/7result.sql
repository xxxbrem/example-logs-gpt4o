WITH income_difference AS (
    SELECT 
        b."state_name",
        b."state_code",
        AVG(c."median_income" - a."median_income") AS "avg_income_difference"
    FROM CENSUS_BUREAU_ACS_2.CENSUS_BUREAU_ACS.ZIP_CODES_2015_5YR a
    INNER JOIN CENSUS_BUREAU_ACS_2.GEO_US_BOUNDARIES.ZIP_CODES b
        ON a."geo_id" = b."zip_code"
    INNER JOIN CENSUS_BUREAU_ACS_2.CENSUS_BUREAU_ACS.ZIP_CODES_2018_5YR c
        ON a."geo_id" = c."geo_id"
    GROUP BY b."state_name", b."state_code"
    ORDER BY "avg_income_difference" DESC NULLS LAST
    LIMIT 5
),
vulnerable_employees AS (
    SELECT 
        b."state_name",
        b."state_code",
        AVG(d."employed_wholesale_trade") * 0.38423645320197042 +
        AVG(d."employed_construction") * 0.48071410777129553 +
        AVG(d."employed_arts_entertainment_recreation_accommodation_food") * 0.89455676291236841 +
        AVG(d."employed_information") * 0.31315240083507306 +
        AVG(d."employed_retail_trade") * 0.51 AS "avg_vulnerable_employees"
    FROM CENSUS_BUREAU_ACS_2.CENSUS_BUREAU_ACS.ZIP_CODES_2015_5YR a
    INNER JOIN CENSUS_BUREAU_ACS_2.GEO_US_BOUNDARIES.ZIP_CODES b
        ON a."geo_id" = b."zip_code"
    INNER JOIN CENSUS_BUREAU_ACS_2.CENSUS_BUREAU_ACS.ZIP_CODES_2017_5YR d
        ON a."geo_id" = d."geo_id"
    GROUP BY b."state_name", b."state_code"
)
SELECT 
    i."state_name", 
    i."state_code", 
    i."avg_income_difference", 
    v."avg_vulnerable_employees"
FROM income_difference i
INNER JOIN vulnerable_employees v
    ON i."state_name" = v."state_name" AND i."state_code" = v."state_code"
ORDER BY i."avg_income_difference" DESC NULLS LAST;