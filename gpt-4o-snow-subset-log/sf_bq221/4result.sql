WITH FirstCPCData AS (
    -- Extract the first CPC code along with relevant publication data
    SELECT 
        "filing_date",
        "family_id",
        f.value::VARIANT:"code"::STRING AS "first_cpc_code"
    FROM 
        PATENTS.PATENTS.PUBLICATIONS t, 
        LATERAL FLATTEN(input => t."cpc") f
    WHERE 
        f.index = 0 -- Only the first CPC code
        AND "filing_date" IS NOT NULL
        AND "application_number" IS NOT NULL
),
YearlyCounts AS (
    -- Aggregate the count of patents per year and CPC code
    SELECT
        FLOOR("filing_date" / 10000) AS "filing_year",
        "first_cpc_code",
        COUNT(DISTINCT "family_id") AS "patent_count"
    FROM
        FirstCPCData
    GROUP BY
        "filing_year", "first_cpc_code"
    HAVING "filing_year" > 1900 -- Filter out invalid years
),
RowNumbers AS (
    -- Assign row numbers to each CPC code by filing year
    SELECT
        "filing_year",
        "first_cpc_code",
        "patent_count",
        ROW_NUMBER() OVER (PARTITION BY "first_cpc_code" ORDER BY "filing_year") AS "row_number"
    FROM
        YearlyCounts
),
ExponentialMovingAverage AS (
    -- Calculate Exponential Moving Average for each CPC code using the assigned row numbers
    SELECT
        r."filing_year",
        r."first_cpc_code",
        r."patent_count",
        SUM(EXP(-(r."row_number") * 0.2) * r."patent_count")
            OVER (PARTITION BY r."first_cpc_code" ORDER BY r."filing_year") AS "ema"
    FROM
        RowNumbers r
),
MaxEMAByCPC AS (
    -- Identify the year with the highest EMA for each CPC code
    SELECT
        "first_cpc_code",
        "filing_year" AS "best_year",
        "ema" AS "max_ema"
    FROM (
        SELECT 
            "filing_year",
            "first_cpc_code",
            "ema",
            ROW_NUMBER() OVER (PARTITION BY "first_cpc_code" ORDER BY "ema" DESC) AS "rank"
        FROM 
            ExponentialMovingAverage
    )
    WHERE 
        "rank" = 1
),
CPCGroupLevel5 AS (
    -- Filter CPC codes at level 5 (specific technology areas) and their full titles
    SELECT
        cd."symbol" AS "cpc_code",
        cd."titleFull" AS "cpc_title"
    FROM
        PATENTS.PATENTS.CPC_DEFINITION cd
    WHERE
        cd."level" = 5
),
FinalResult AS (
    -- Join the CPC group metadata with the Max EMA results
    SELECT
        m."first_cpc_code" AS "cpc_code",
        c."cpc_title",
        m."best_year",
        m."max_ema"
    FROM 
        MaxEMAByCPC m
    LEFT JOIN 
        CPCGroupLevel5 c
    ON 
        m."first_cpc_code" = c."cpc_code"
)
-- Final output
SELECT 
    "cpc_code",
    "cpc_title",
    "best_year",
    "max_ema"
FROM 
    FinalResult
ORDER BY 
    "max_ema" DESC NULLS LAST
LIMIT 100;