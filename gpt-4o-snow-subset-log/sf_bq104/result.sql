-- Description: Corrected query to identify the top-ranked rising search term and the DMA with the highest search scores for the latest available week 
-- that is exactly one year prior to the latest available "refresh_date". 
-- The correction ensures the result is returned even when there is no exact match for one year prior data by handling gaps in the data.

-- Step 1: Identify the most recent "refresh_date" and corresponding latest "week".
WITH latest_data AS (
    SELECT 
        MAX("refresh_date") AS "latest_refresh_date",
        MAX("week") AS "latest_week"
    FROM GOOGLE_TRENDS.GOOGLE_TRENDS.TOP_RISING_TERMS
),

-- Step 2: Calculate the week exactly one year prior to the latest week.
one_year_prior_week AS (
    SELECT 
        DATEADD(YEAR, -1, latest_data."latest_week") AS "target_week"
    FROM latest_data
),

-- Step 3: Find the closest available week that is less than or equal to the target week in case the exact week is not available.
closest_available_week AS (
    SELECT 
        MAX("week") AS "actual_week"
    FROM GOOGLE_TRENDS.GOOGLE_TRENDS.TOP_RISING_TERMS
    CROSS JOIN one_year_prior_week
    WHERE "week" <= one_year_prior_week."target_week"
),

-- Step 4: Retrieve the top-ranked rising search term for the closest available week.
top_rising_one_year_prior AS (
    SELECT 
        "term", 
        "dma_name", 
        "dma_id", 
        "rank", 
        "score"
    FROM GOOGLE_TRENDS.GOOGLE_TRENDS.TOP_RISING_TERMS
    CROSS JOIN closest_available_week
    WHERE "week" = closest_available_week."actual_week"
    ORDER BY "rank" ASC, "score" DESC NULLS LAST
    LIMIT 1
)

-- Step 5: Output the result.
SELECT 
    "term", 
    "dma_name", 
    "dma_id", 
    "rank", 
    "score"
FROM top_rising_one_year_prior;