WITH CommuteMetrics AS (
    -- Filter for MetricID that represents commuters traveling over one hour
    SELECT 
        "ZipCode", 
        CAST("CensusValueByZip" AS FLOAT) AS "TotalCommuters",
        "MetricID"
    FROM "CENSUS_GALAXY__AIML_MODEL_DATA_ENRICHMENT_SAMPLE"."PUBLIC"."Fact_CensusValues_ACS2021_ByZip"
    WHERE "MetricID" = 'B08303_012E' -- Metric for commuters over one hour
),
FilteredByNY AS (
    -- Join with LU_GeographyExpanded to filter only NY zip codes
    SELECT 
        c."ZipCode", 
        c."TotalCommuters",
        l."PreferredStateAbbrev",
        l."PreferredStateName"
    FROM CommuteMetrics c
    INNER JOIN "CENSUS_GALAXY__AIML_MODEL_DATA_ENRICHMENT_SAMPLE"."PUBLIC"."LU_GeographyExpanded" l
    ON c."ZipCode" = l."ZipCode"
    WHERE l."PreferredStateAbbrev" = 'NY'
),
StateBenchmark AS (
    -- Get the benchmark and total state population for NY
    SELECT 
        "MetricID", 
        "StateBenchmarkValue",
        "TotalStatePopulation"
    FROM "CENSUS_GALAXY__AIML_MODEL_DATA_ENRICHMENT_SAMPLE"."PUBLIC"."Fact_StateBenchmark_ACS2021"
    WHERE "StateAbbrev" = 'NY'
      AND "MetricID" = 'B08303_012E' -- Metric for commuters over one hour
),
Result AS (
    -- Combine the NY zip code data with the benchmark and total state population
    SELECT 
        f."ZipCode", 
        f."TotalCommuters", 
        s."StateBenchmarkValue",
        s."TotalStatePopulation"
    FROM FilteredByNY f
    CROSS JOIN StateBenchmark s
)
-- Retrieve the ZIP code with the highest number of commuters traveling over one hour
SELECT 
    "ZipCode", 
    "TotalCommuters", 
    "StateBenchmarkValue", 
    "TotalStatePopulation"
FROM Result
ORDER BY "TotalCommuters" DESC NULLS LAST
LIMIT 1;