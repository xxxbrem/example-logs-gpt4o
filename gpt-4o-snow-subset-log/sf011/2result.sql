WITH TractTotals AS (
    SELECT 
        G."StateCountyTractID", 
        SUM(F."CensusValue") AS "TotalTractPopulation"
    FROM 
        "CENSUS_GALAXY__ZIP_CODE_TO_BLOCK_GROUP_SAMPLE"."PUBLIC"."Dim_CensusGeography" G
    JOIN 
        "CENSUS_GALAXY__ZIP_CODE_TO_BLOCK_GROUP_SAMPLE"."PUBLIC"."Fact_CensusValues_ACS2021" F
    ON 
        G."BlockGroupID" = F."BlockGroupID"
    WHERE 
        G."StateName" = 'New York' -- Filter for New York State
    GROUP BY 
        G."StateCountyTractID"
)
SELECT 
    G."BlockGroupID", 
    F."CensusValue", 
    G."StateCountyTractID", 
    T."TotalTractPopulation",
    F."CensusValue" / T."TotalTractPopulation" AS "PopulationRatio"
FROM 
    "CENSUS_GALAXY__ZIP_CODE_TO_BLOCK_GROUP_SAMPLE"."PUBLIC"."Dim_CensusGeography" G
JOIN 
    "CENSUS_GALAXY__ZIP_CODE_TO_BLOCK_GROUP_SAMPLE"."PUBLIC"."Fact_CensusValues_ACS2021" F
ON 
    G."BlockGroupID" = F."BlockGroupID"
JOIN 
    TractTotals T
ON 
    G."StateCountyTractID" = T."StateCountyTractID"
WHERE 
    G."StateName" = 'New York' -- Filter for New York State
ORDER BY 
    G."StateCountyTractID", G."BlockGroupID"
LIMIT 20;