WITH IncomeDifference AS (
  SELECT z."state_name", 
         AVG(t2018."median_income" - t2015."median_income") AS "avg_income_difference"
  FROM CENSUS_BUREAU_ACS_2.GEO_US_BOUNDARIES.ZIP_CODES z
  JOIN CENSUS_BUREAU_ACS_2.CENSUS_BUREAU_ACS.ZIP_CODES_2015_5YR t2015
    ON z."zip_code" = t2015."geo_id"
  JOIN CENSUS_BUREAU_ACS_2.CENSUS_BUREAU_ACS.ZIP_CODES_2018_5YR t2018
    ON t2015."geo_id" = t2018."geo_id"
  WHERE t2015."median_income" IS NOT NULL AND t2018."median_income" IS NOT NULL
  GROUP BY z."state_name"
),
Vulnerability AS (
  SELECT z."state_name",
         AVG(
          ("employed_wholesale_trade" * 0.38423645320197042 +
           ("employed_agriculture_forestry_fishing_hunting_mining" + "employed_construction") * 0.48071410777129553 +
           "employed_arts_entertainment_recreation_accommodation_food" * 0.89455676291236841 +
           "employed_information" * 0.31315240083507306 +
           "employed_retail_trade" * 0.51)
         ) AS "avg_vulnerable_employees"
  FROM CENSUS_BUREAU_ACS_2.GEO_US_BOUNDARIES.ZIP_CODES z
  JOIN CENSUS_BUREAU_ACS_2.CENSUS_BUREAU_ACS.ZIP_CODES_2017_5YR t
    ON z."zip_code" = t."geo_id"
  GROUP BY z."state_name"
)
SELECT id."state_name", id."avg_income_difference", v."avg_vulnerable_employees"
FROM IncomeDifference id
JOIN Vulnerability v
  ON id."state_name" = v."state_name"
ORDER BY id."avg_income_difference" DESC NULLS LAST
LIMIT 5;