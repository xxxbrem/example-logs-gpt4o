WITH income_difference AS (
    SELECT a."state_name",
           AVG(b."median_income" - a."median_income") AS "average_median_income_difference"
    FROM (SELECT z."state_name", i."geo_id", i."median_income"
          FROM CENSUS_BUREAU_ACS_2.GEO_US_BOUNDARIES.ZIP_CODES z
          JOIN CENSUS_BUREAU_ACS_2.CENSUS_BUREAU_ACS.ZIP_CODES_2015_5YR i
          ON z."zip_code" = i."geo_id") a
    JOIN (SELECT z2."state_name", i2."geo_id", i2."median_income"
          FROM CENSUS_BUREAU_ACS_2.GEO_US_BOUNDARIES.ZIP_CODES z2
          JOIN CENSUS_BUREAU_ACS_2.CENSUS_BUREAU_ACS.ZIP_CODES_2018_5YR i2
          ON z2."zip_code" = i2."geo_id") b
    ON a."state_name" = b."state_name" AND a."geo_id" = b."geo_id"
    GROUP BY a."state_name"
    ORDER BY "average_median_income_difference" DESC NULLS LAST
    LIMIT 5
),
vulnerable_employees AS (
    SELECT z."state_name",
           AVG(e."employed_wholesale_trade") * 0.38423645320197042 +
           AVG(e."employed_construction") * 0.48071410777129553 +
           AVG(e."employed_arts_entertainment_recreation_accommodation_food") * 0.89455676291236841 +
           AVG(e."employed_information") * 0.31315240083507306 +
           AVG(e."employed_retail_trade") * 0.51 AS "average_vulnerable_employees"
    FROM CENSUS_BUREAU_ACS_2.GEO_US_BOUNDARIES.ZIP_CODES z
    JOIN CENSUS_BUREAU_ACS_2.CENSUS_BUREAU_ACS.ZIP_CODES_2017_5YR e
    ON z."zip_code" = e."geo_id"
    GROUP BY z."state_name"
)
SELECT i."state_name",
       i."average_median_income_difference",
       v."average_vulnerable_employees"
FROM income_difference i
JOIN vulnerable_employees v
ON i."state_name" = v."state_name"
ORDER BY i."average_median_income_difference" DESC NULLS LAST;