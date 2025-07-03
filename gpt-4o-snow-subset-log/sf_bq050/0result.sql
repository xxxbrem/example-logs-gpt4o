WITH WEATHER_DATA AS (
  -- Step 1: Filter weather data for Central Park station in 2014
  SELECT 
    "stn",
    TO_DATE(CONCAT("year", '-', "mo", '-', "da")) AS "date",
    "temp" AS "avg_temp_f",
    ROUND("wdsp"::FLOAT * 0.51444, 1) AS "avg_wdsp_mps", -- Convert wind speed from knots to meters/second
    ROUND("prcp" * 2.54, 1) AS "avg_prcp_cm" -- Convert precipitation from inches to centimeters
  FROM "NEW_YORK_CITIBIKE_1"."NOAA_GSOD"."GSOD2014"
  WHERE "stn" = '725030' AND "year" = '2014'
    AND "temp" != 9999.9 
    AND "wdsp" != 999.9 
    AND "prcp" != 99.99
),
TRIP_DATA AS (
  -- Step 2: Filter Citibike trip data for 2014 and enrich with start/stop neighborhoods
  SELECT 
    t."start_station_id",
    t."end_station_id",
    TO_DATE(TO_TIMESTAMP(t."starttime" / 1e6)) AS "trip_date",
    ROUND(t."tripduration" / 60, 1) AS "trip_duration_minutes",
    start_z."neighborhood" AS "start_neighborhood",
    end_z."neighborhood" AS "end_neighborhood",
    EXTRACT(MONTH FROM TO_TIMESTAMP(t."starttime" / 1e6)) AS "trip_month"
  FROM "NEW_YORK_CITIBIKE_1"."NEW_YORK_CITIBIKE"."CITIBIKE_TRIPS" t
  LEFT JOIN "NEW_YORK_CITIBIKE_1"."CYCLISTIC"."ZIP_CODES" start_z 
    ON t."start_station_id" = start_z."zip"
  LEFT JOIN "NEW_YORK_CITIBIKE_1"."CYCLISTIC"."ZIP_CODES" end_z 
    ON t."end_station_id" = end_z."zip"
  WHERE EXTRACT(YEAR FROM TO_TIMESTAMP(t."starttime" / 1e6)) = 2014
),
ENRICHED_DATA AS (
  -- Step 3: Join trip data with weather data using trip date
  SELECT 
    td."start_neighborhood",
    td."end_neighborhood",
    td."trip_duration_minutes",
    td."trip_date",
    td."trip_month",
    wd."avg_temp_f",
    wd."avg_wdsp_mps",
    wd."avg_prcp_cm"
  FROM TRIP_DATA td
  LEFT JOIN WEATHER_DATA wd
    ON td."trip_date" = wd."date"
),
TRIP_MONTH_STATS AS (
  -- Step 4: Calculate the most trips month (trip_month with most occurrences) for each start/end neighborhood combination
  SELECT 
    ed."start_neighborhood",
    ed."end_neighborhood",
    ed."trip_month",
    COUNT(*) AS "trip_count",
    ROW_NUMBER() OVER (PARTITION BY ed."start_neighborhood", ed."end_neighborhood" ORDER BY COUNT(*) DESC) AS "row_num"
  FROM ENRICHED_DATA ed
  GROUP BY ed."start_neighborhood", ed."end_neighborhood", ed."trip_month"
),
MOST_TRIPS_MONTH AS (
  -- Step 5: Filter to get the most trips month using the row number
  SELECT 
    "start_neighborhood",
    "end_neighborhood",
    "trip_month" AS "most_trips_month"
  FROM TRIP_MONTH_STATS
  WHERE "row_num" = 1
),
ANALYSIS AS (
  -- Step 6: Aggregate data grouped by starting and ending neighborhoods
  SELECT 
    ed."start_neighborhood",
    ed."end_neighborhood",
    COUNT(*) AS "total_trips",
    ROUND(AVG(ed."trip_duration_minutes"), 1) AS "avg_trip_duration_minutes",
    ROUND(AVG(ed."avg_temp_f"), 1) AS "avg_temp_f",
    ROUND(AVG(ed."avg_wdsp_mps"), 1) AS "avg_wdsp_mps",
    ROUND(AVG(ed."avg_prcp_cm"), 1) AS "avg_prcp_cm"
  FROM ENRICHED_DATA ed
  GROUP BY ed."start_neighborhood", ed."end_neighborhood"
)
-- Step 7: Combine analysis with most trips month
SELECT 
  a."start_neighborhood",
  a."end_neighborhood",
  a."total_trips",
  a."avg_trip_duration_minutes",
  a."avg_temp_f",
  a."avg_wdsp_mps",
  a."avg_prcp_cm",
  mtm."most_trips_month"
FROM ANALYSIS a
LEFT JOIN MOST_TRIPS_MONTH mtm
  ON a."start_neighborhood" = mtm."start_neighborhood"
  AND a."end_neighborhood" = mtm."end_neighborhood"
ORDER BY a."total_trips" DESC NULLS LAST
LIMIT 50;