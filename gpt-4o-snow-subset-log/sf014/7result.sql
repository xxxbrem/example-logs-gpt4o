WITH CommuterMetrics AS (
    SELECT 
        "Fact_CensusValues_ACS2021_ByZip"."ZipCode",
        "Fact_CensusValues_ACS2021_ByZip"."CensusValueByZip" AS "TotalCommuters",
        "Fact_StateBenchmark_ACS2021"."StateBenchmarkValue" AS "StateBenchmark",
        "Fact_StateBenchmark_ACS2021"."TotalStatePopulation",
        "LU_GeographyExpanded"."PreferredStateAbbrev"
    FROM CENSUS_GALAXY__AIML_MODEL_DATA_ENRICHMENT_SAMPLE.PUBLIC."Fact_CensusValues_ACS2021_ByZip"
    INNER JOIN CENSUS_GALAXY__AIML_MODEL_DATA_ENRICHMENT_SAMPLE.PUBLIC."Fact_StateBenchmark_ACS2021"
        ON "Fact_CensusValues_ACS2021_ByZip"."MetricID" = "Fact_StateBenchmark_ACS2021"."MetricID"
    INNER JOIN CENSUS_GALAXY__AIML_MODEL_DATA_ENRICHMENT_SAMPLE.PUBLIC."LU_GeographyExpanded"
        ON "Fact_CensusValues_ACS2021_ByZip"."ZipCode" = "LU_GeographyExpanded"."ZipCode"
    WHERE 
        "Fact_StateBenchmark_ACS2021"."StateAbbrev" = 'NY'
        AND "Fact_CensusValues_ACS2021_ByZip"."MetricID" = 'B08303_012E' -- Metric for commuting over an hour
        AND "LU_GeographyExpanded"."PreferredStateAbbrev" = 'NY'
)
SELECT 
    "ZipCode",
    "TotalCommuters",
    "StateBenchmark",
    "TotalStatePopulation"
FROM CommuterMetrics
ORDER BY "TotalCommuters" DESC NULLS LAST
LIMIT 1;