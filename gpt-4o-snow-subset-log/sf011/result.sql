WITH BlockGroupPopulation AS (
    SELECT 
        geo."BlockGroupID", 
        fact."CensusValue", 
        geo."StateCountyTractID"
    FROM 
        "CENSUS_GALAXY__ZIP_CODE_TO_BLOCK_GROUP_SAMPLE"."PUBLIC"."Fact_CensusValues_ACS2021" fact
    JOIN 
        "CENSUS_GALAXY__ZIP_CODE_TO_BLOCK_GROUP_SAMPLE"."PUBLIC"."Dim_CensusMetrics" metrics
        ON fact."MetricID" = metrics."MetricID"
    JOIN 
        "CENSUS_GALAXY__ZIP_CODE_TO_BLOCK_GROUP_SAMPLE"."PUBLIC"."Dim_CensusGeography" geo
        ON fact."BlockGroupID" = geo."BlockGroupID"
    WHERE 
        geo."StateAbbrev" = 'NY'
),
TractPopulation AS (
    SELECT 
        geo."StateCountyTractID", 
        SUM(fact."CensusValue") AS "TotalTractPopulation"
    FROM 
        "CENSUS_GALAXY__ZIP_CODE_TO_BLOCK_GROUP_SAMPLE"."PUBLIC"."Fact_CensusValues_ACS2021" fact
    JOIN 
        "CENSUS_GALAXY__ZIP_CODE_TO_BLOCK_GROUP_SAMPLE"."PUBLIC"."Dim_CensusMetrics" metrics
        ON fact."MetricID" = metrics."MetricID"
    JOIN 
        "CENSUS_GALAXY__ZIP_CODE_TO_BLOCK_GROUP_SAMPLE"."PUBLIC"."Dim_CensusGeography" geo
        ON fact."BlockGroupID" = geo."BlockGroupID"
    WHERE 
        geo."StateAbbrev" = 'NY'
    GROUP BY 
        geo."StateCountyTractID"
)
SELECT 
    bgp."BlockGroupID", 
    bgp."CensusValue", 
    bgp."StateCountyTractID", 
    tp."TotalTractPopulation",
    (bgp."CensusValue" / NULLIF(tp."TotalTractPopulation", 0)) AS "PopulationRatio"
FROM 
    BlockGroupPopulation bgp
JOIN 
    TractPopulation tp
    ON bgp."StateCountyTractID" = tp."StateCountyTractID"
ORDER BY 
    bgp."BlockGroupID"
LIMIT 20;