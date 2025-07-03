SELECT 
    g."BlockGroupID", 
    f."CensusValue" AS "BlockGroupPopulation", 
    g."StateCountyTractID", 
    SUM(f."CensusValue") OVER (PARTITION BY g."StateCountyTractID") AS "TotalTractPopulation",
    f."CensusValue" / SUM(f."CensusValue") OVER (PARTITION BY g."StateCountyTractID") AS "PopulationRatio"
FROM 
    "CENSUS_GALAXY__ZIP_CODE_TO_BLOCK_GROUP_SAMPLE"."PUBLIC"."Fact_CensusValues_ACS2021" AS f
JOIN 
    "CENSUS_GALAXY__ZIP_CODE_TO_BLOCK_GROUP_SAMPLE"."PUBLIC"."Dim_CensusGeography" AS g
ON 
    f."BlockGroupID" = g."BlockGroupID"
WHERE 
    g."StateFIPS" = '36' -- New York State
    AND f."MetricID" IN (
        SELECT "MetricID"
        FROM "CENSUS_GALAXY__ZIP_CODE_TO_BLOCK_GROUP_SAMPLE"."PUBLIC"."Dim_CensusMetrics"
        WHERE "MetricCategory" ILIKE '%Demographics%' OR "MetricCategory" ILIKE '%Population%'
    )
LIMIT 100;