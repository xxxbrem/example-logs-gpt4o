SELECT 
    g."BlockGroupID", 
    f."CensusValue", 
    g."StateCountyTractID", 
    t."TotalTractPopulation", 
    (f."CensusValue" / t."TotalTractPopulation") AS "PopulationRatio"
FROM 
    "CENSUS_GALAXY__ZIP_CODE_TO_BLOCK_GROUP_SAMPLE"."PUBLIC"."Dim_CensusGeography" g
JOIN 
    "CENSUS_GALAXY__ZIP_CODE_TO_BLOCK_GROUP_SAMPLE"."PUBLIC"."Fact_CensusValues_ACS2021" f
ON 
    g."BlockGroupID" = f."BlockGroupID"
JOIN (
    SELECT 
        "StateCountyTractID", 
        SUM("CensusValue") AS "TotalTractPopulation"
    FROM 
        "CENSUS_GALAXY__ZIP_CODE_TO_BLOCK_GROUP_SAMPLE"."PUBLIC"."Fact_CensusValues_ACS2021" f
    JOIN 
        "CENSUS_GALAXY__ZIP_CODE_TO_BLOCK_GROUP_SAMPLE"."PUBLIC"."Dim_CensusGeography" g
    ON 
        f."BlockGroupID" = g."BlockGroupID"
    WHERE 
        g."StateName" ILIKE '%New York%'
    GROUP BY 
        "StateCountyTractID"
) t
ON 
    g."StateCountyTractID" = t."StateCountyTractID"
LIMIT 20;