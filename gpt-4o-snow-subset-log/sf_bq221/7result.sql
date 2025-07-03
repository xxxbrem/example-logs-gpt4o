WITH First_CPC AS (
    -- Extract the first CPC code and associated filing date for valid patents
    SELECT 
        t."publication_number", 
        f.value::VARIANT:"code"::STRING AS "CPC_code", 
        t."filing_date"
    FROM PATENTS.PATENTS.PUBLICATIONS t, 
    LATERAL FLATTEN(input => t."cpc") f
    WHERE f.value::VARIANT:"first"::BOOLEAN = TRUE
        AND t."filing_date" IS NOT NULL
        AND t."application_number" IS NOT NULL
),
Yearly_Filing_Count AS (
    -- Aggregate patent filing counts by CPC code and year
    SELECT 
        "CPC_code", 
        EXTRACT(YEAR FROM DATE_FROM_PARTS(TO_NUMBER(SUBSTR("filing_date"::TEXT, 1, 4)), 1, 1)) AS "filing_year",
        COUNT(*) AS "filing_count"
    FROM First_CPC
    GROUP BY "CPC_code", EXTRACT(YEAR FROM DATE_FROM_PARTS(TO_NUMBER(SUBSTR("filing_date"::TEXT, 1, 4)), 1, 1))
),
EMA_Helper AS (
    -- Assign a sequential row number for each year within a CPC group
    SELECT 
        "CPC_code",
        "filing_year",
        "filing_count",
        ROW_NUMBER() OVER (PARTITION BY "CPC_code" ORDER BY "filing_year") - 1 AS "row_number"
    FROM Yearly_Filing_Count
),
EMA_Calculation AS (
    -- Calculate the exponential moving average (EMA) manually for each CPC code
    SELECT 
        h."CPC_code",
        h."filing_year",
        h."filing_count",
        SUM(h."filing_count" * POWER(1 - 0.2, h."row_number")) OVER (
            PARTITION BY h."CPC_code"
            ORDER BY h."row_number") AS "ema_filing_count"
    FROM EMA_Helper h
),
Max_EMA_Per_CPC AS (
    -- Find the year with the highest EMA for each CPC code
    SELECT 
        "CPC_code",
        "filing_year" AS "best_year",
        MAX("ema_filing_count") AS "max_ema"
    FROM EMA_Calculation
    GROUP BY "CPC_code", "filing_year"
    QUALIFY ROW_NUMBER() OVER (PARTITION BY "CPC_code" ORDER BY "max_ema" DESC) = 1
),
CPC_Level_5 AS (
    -- Get CPC definitions at level 5
    SELECT 
        "symbol", 
        "titleFull"
    FROM PATENTS.PATENTS.CPC_DEFINITION
    WHERE "level" = 5
),
Final_Result AS (
    -- Join EMA results with CPC title information
    SELECT 
        m."CPC_code",
        c."titleFull" AS "CPC_title",
        m."best_year",
        m."max_ema"
    FROM Max_EMA_Per_CPC m
    LEFT JOIN CPC_Level_5 c
    ON m."CPC_code" = c."symbol"
)
-- Output the final result
SELECT * 
FROM Final_Result
ORDER BY "max_ema" DESC NULLS LAST;