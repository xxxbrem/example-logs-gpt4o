WITH TractPopulation AS (
  SELECT 
    g."StateCountyTractID", 
    SUM(f."CensusValue") AS "TotalTractPopulation"
  FROM 
    "CENSUS_GALAXY__ZIP_CODE_TO_BLOCK_GROUP_SAMPLE"."PUBLIC"."Fact_CensusValues_ACS2021" f
  JOIN 
    "CENSUS_GALAXY__ZIP_CODE_TO_BLOCK_GROUP_SAMPLE"."PUBLIC"."Dim_CensusGeography" g
  ON 
    f."BlockGroupID" = g."BlockGroupID"
  WHERE 
    g."StateAbbrev" = 'NY'
  GROUP BY 
    g."StateCountyTractID"
)
SELECT 
  f."BlockGroupID", 
  f."CensusValue", 
  g."StateCountyTractID", 
  t."TotalTractPopulation",
  (f."CensusValue" / t."TotalTractPopulation") AS "PopulationRatio"
FROM 
  "CENSUS_GALAXY__ZIP_CODE_TO_BLOCK_GROUP_SAMPLE"."PUBLIC"."Fact_CensusValues_ACS2021" f
JOIN 
  "CENSUS_GALAXY__ZIP_CODE_TO_BLOCK_GROUP_SAMPLE"."PUBLIC"."Dim_CensusGeography" g
ON 
  f."BlockGroupID" = g."BlockGroupID"
JOIN 
  TractPopulation t
ON 
  g."StateCountyTractID" = t."StateCountyTractID"
WHERE 
  g."StateAbbrev" = 'NY'
LIMIT 20;