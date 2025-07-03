WITH TotalTractPopulation AS (
    SELECT 
        g."StateCountyTractID", 
        SUM(f."CensusValue") AS "TotalTractPopulation"
    FROM 
        CENSUS_GALAXY__ZIP_CODE_TO_BLOCK_GROUP_SAMPLE.PUBLIC."Dim_CensusGeography" g
    JOIN (
        SELECT 
            f."BlockGroupID", 
            f."CensusValue"
        FROM 
            CENSUS_GALAXY__ZIP_CODE_TO_BLOCK_GROUP_SAMPLE.PUBLIC."Fact_CensusValues_ACS2021" f
        JOIN 
            CENSUS_GALAXY__ZIP_CODE_TO_BLOCK_GROUP_SAMPLE.PUBLIC."Dim_CensusMetrics" d 
            ON f."MetricID" = d."MetricID"
        WHERE 
            d."MetricCategory" ILIKE '%Demographics%' 
            AND d."UnitMeasureType" ILIKE '%People%'
    ) f 
    ON g."BlockGroupID" = f."BlockGroupID"
    WHERE 
        g."StateAbbrev" = 'NY'
    GROUP BY 
        g."StateCountyTractID"
)
SELECT 
    g."BlockGroupID", 
    f."CensusValue", 
    g."StateCountyTractID", 
    t."TotalTractPopulation", 
    (f."CensusValue" / t."TotalTractPopulation") AS "PopulationRatio"
FROM 
    CENSUS_GALAXY__ZIP_CODE_TO_BLOCK_GROUP_SAMPLE.PUBLIC."Dim_CensusGeography" g
JOIN (
    SELECT 
        f."BlockGroupID", 
        f."CensusValue"
    FROM 
        CENSUS_GALAXY__ZIP_CODE_TO_BLOCK_GROUP_SAMPLE.PUBLIC."Fact_CensusValues_ACS2021" f
    JOIN 
        CENSUS_GALAXY__ZIP_CODE_TO_BLOCK_GROUP_SAMPLE.PUBLIC."Dim_CensusMetrics" d 
        ON f."MetricID" = d."MetricID"
    WHERE 
        d."MetricCategory" ILIKE '%Demographics%' 
        AND d."UnitMeasureType" ILIKE '%People%'
) f 
ON g."BlockGroupID" = f."BlockGroupID"
JOIN 
    TotalTractPopulation t 
ON g."StateCountyTractID" = t."StateCountyTractID"
WHERE 
    g."StateAbbrev" = 'NY'
LIMIT 20;