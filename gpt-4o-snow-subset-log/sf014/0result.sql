SELECT 
    z."ZipCode", 
    z."CensusValueByZip" AS "TotalCommutersOverOneHour", 
    s."StateBenchmarkValue" AS "NYStateBenchmarkCommutersOverOneHour", 
    s."TotalStatePopulation"
FROM 
    "CENSUS_GALAXY__AIML_MODEL_DATA_ENRICHMENT_SAMPLE"."PUBLIC"."Fact_CensusValues_ACS2021_ByZip" z
JOIN 
    "CENSUS_GALAXY__AIML_MODEL_DATA_ENRICHMENT_SAMPLE"."PUBLIC"."Dim_CensusMetrics" m
    ON z."MetricID" = m."MetricID"
JOIN 
    "CENSUS_GALAXY__AIML_MODEL_DATA_ENRICHMENT_SAMPLE"."PUBLIC"."Fact_StateBenchmark_ACS2021" s
    ON z."MetricID" = s."MetricID"
JOIN 
    "CENSUS_GALAXY__AIML_MODEL_DATA_ENRICHMENT_SAMPLE"."PUBLIC"."LU_GeographyExpanded" g
    ON z."ZipCode" = g."ZipCode"
WHERE 
    m."MetricTableID" = 'B08303' 
    AND (m."Descriptor1" LIKE '%60 to 89 minutes%' OR m."Descriptor1" LIKE '%90 or more minutes%') 
    AND g."PreferredStateAbbrev" = 'NY'
ORDER BY 
    z."CensusValueByZip" DESC NULLS LAST
LIMIT 1;