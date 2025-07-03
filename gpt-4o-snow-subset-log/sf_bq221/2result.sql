WITH FILTERED_PUBLICATIONS AS (
    SELECT 
        substr(CAST(p."filing_date" AS STRING), 1, 4) AS "filing_year",
        f.value::VARIANT:"code"::STRING AS "cpc_code",
        p."application_number"
    FROM PATENTS.PATENTS.PUBLICATIONS p, 
         LATERAL FLATTEN(input => p."cpc") f
    WHERE p."filing_date" IS NOT NULL
      AND p."application_number" IS NOT NULL
      AND f.value::VARIANT:"code" IS NOT NULL
      AND f.value::VARIANT:"first"::BOOLEAN = TRUE -- Consider only the first CPC code
),
AGG_LEVEL5_PUBLICATIONS AS (
    SELECT 
        fp."filing_year",
        fp."cpc_code",
        c."symbol" AS "cpc_code_matched",
        c."titleFull" AS "cpc_title"
    FROM FILTERED_PUBLICATIONS fp
    LEFT JOIN PATENTS.PATENTS.CPC_DEFINITION c 
    ON c."symbol" = fp."cpc_code"
    WHERE c."level" = 5 -- Limit to CPC level 5 groups
      OR c."symbol" IS NOT NULL -- Include rows with matched CPC codes even if level isn't specified
),
YEARLY_PATENT_COUNTS AS (
    SELECT 
        "cpc_code_matched",
        "cpc_title",
        "filing_year",
        COUNT(*) AS "patent_count"
    FROM AGG_LEVEL5_PUBLICATIONS
    WHERE "cpc_code_matched" IS NOT NULL -- Ensure valid matches
    GROUP BY "cpc_code_matched", "cpc_title", "filing_year"
),
ROW_NUMBERED_PATENTS AS (
    SELECT 
        "cpc_code_matched",
        "cpc_title",
        "filing_year",
        "patent_count",
        ROW_NUMBER() OVER (
            PARTITION BY "cpc_code_matched" 
            ORDER BY "filing_year" ASC
        ) AS "row_num"
    FROM YEARLY_PATENT_COUNTS
),
WEIGHTED_PATENT_COUNTS AS (
    SELECT 
        "cpc_code_matched",
        "cpc_title",
        "filing_year",
        "patent_count",
        POWER(0.8, "row_num" - 1) AS "decay_weight",
        "patent_count" * POWER(0.8, "row_num" - 1) AS "weighted_patent_count"
    FROM ROW_NUMBERED_PATENTS
),
EMA_CALCULATION AS (
    SELECT 
        "cpc_code_matched",
        "cpc_title",
        "filing_year",
        SUM("weighted_patent_count") OVER (
            PARTITION BY "cpc_code_matched" 
            ORDER BY "filing_year" ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS "ema_value"
    FROM WEIGHTED_PATENT_COUNTS
),
BEST_YEAR_PER_CPC AS (
    SELECT
        "cpc_code_matched",
        "cpc_title",
        "filing_year" AS "best_year",
        "ema_value"
    FROM (
        SELECT
            "cpc_code_matched",
            "cpc_title",
            "filing_year",
            "ema_value",
            ROW_NUMBER() OVER (
                PARTITION BY "cpc_code_matched" 
                ORDER BY "ema_value" DESC NULLS LAST
            ) AS "rank"
        FROM EMA_CALCULATION
    ) ranked
    WHERE "rank" = 1
)
SELECT 
    "cpc_code_matched",
    "cpc_title",
    "best_year",
    "ema_value" AS "highest_ema"
FROM BEST_YEAR_PER_CPC
ORDER BY "highest_ema" DESC NULLS LAST;