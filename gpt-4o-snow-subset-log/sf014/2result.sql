WITH CommutersOverOneHour AS (
    SELECT 
        fc."ZipCode", 
        fc."CensusValueByZip" AS "TotalCommuters", 
        fc."MetricID", 
        dcm."MetricTableDesc", 
        dcm."Descriptor1", 
        dcm."Descriptor2", 
        dcm."Descriptor3"
    FROM 
        "CENSUS_GALAXY__AIML_MODEL_DATA_ENRICHMENT_SAMPLE"."PUBLIC"."Fact_CensusValues_ACS2021_ByZip" fc
    JOIN 
        "CENSUS_GALAXY__AIML_MODEL_DATA_ENRICHMENT_SAMPLE"."PUBLIC"."Dim_CensusMetrics" dcm 
        ON fc."MetricID" = dcm."MetricID"
    WHERE 
        dcm."MetricTableDesc" ILIKE '%commut%one hour%' 
        OR dcm."Descriptor1" ILIKE '%commut%' 
        OR dcm."Descriptor2" ILIKE '%commut%' 
        OR dcm."Descriptor3" ILIKE '%commut%'
),
FilteredNY AS (
    SELECT 
        co."ZipCode", 
        co."TotalCommuters", 
        co."MetricID", 
        cge."PreferredStateAbbrev", 
        cge."PreferredStateName"
    FROM 
        CommutersOverOneHour co
    JOIN 
        "CENSUS_GALAXY__AIML_MODEL_DATA_ENRICHMENT_SAMPLE"."PUBLIC"."LU_GeographyExpanded" cge
        ON co."ZipCode" = cge."ZipCode"
    WHERE 
        cge."PreferredStateAbbrev" = 'NY'
),
StateBenchmarkData AS (
    SELECT 
        sb."StateBenchmarkValue", 
        sb."TotalStatePopulation"
    FROM 
        "CENSUS_GALAXY__AIML_MODEL_DATA_ENRICHMENT_SAMPLE"."PUBLIC"."Fact_StateBenchmark_ACS2021" sb
    WHERE 
        sb."MetricID" IN (
            SELECT DISTINCT co."MetricID"
            FROM CommutersOverOneHour co
        )
        AND sb."StateAbbrev" = 'NY'
)
SELECT 
    fn."ZipCode", 
    fn."TotalCommuters", 
    sbd."StateBenchmarkValue", 
    sbd."TotalStatePopulation"
FROM 
    FilteredNY fn
CROSS JOIN 
    StateBenchmarkData sbd
ORDER BY 
    fn."TotalCommuters" DESC NULLS LAST
LIMIT 1;