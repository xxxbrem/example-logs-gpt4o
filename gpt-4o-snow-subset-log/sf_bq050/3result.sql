WITH weather_data AS (
    -- Combine weather data from the 2014 dataset for Central Park station
    SELECT 
        "year", "mo" AS "month", "da" AS "day", 
        CAST("stn" AS STRING) AS "station_id",
        "temp" AS "avg_temp_f", 
        TRY_CAST("wdsp" AS FLOAT) AS "avg_wind_speed_knots", 
        "prcp" AS "precipitation_inches"
    FROM "NEW_YORK_CITIBIKE_1"."NOAA_GSOD"."GSOD2014"
    WHERE "stn" = '725033' -- Central Park station
),
trip_data AS (
    -- Extract trip data from CITIBIKE_TRIPS table for the year 2014
    SELECT 
        "tripduration", 
        TO_TIMESTAMP("starttime" / 1000000) AS "start_date", 
        TO_TIMESTAMP("stoptime" / 1000000) AS "stop_date", 
        "start_station_latitude", "start_station_longitude",
        "end_station_latitude", "end_station_longitude"
    FROM "NEW_YORK_CITIBIKE_1"."NEW_YORK_CITIBIKE"."CITIBIKE_TRIPS"
    WHERE "starttime" BETWEEN 1388534400000000 AND 1420070399000000 -- Filter for the year 2014
),
mapped_start_neighborhoods AS (
    -- Map trip start latitude/longitude to ZIP codes for start neighborhood details
    SELECT 
        t.*,
        z."city" AS "start_city", 
        c."borough" AS "start_borough", 
        c."neighborhood" AS "start_neighborhood"
    FROM trip_data t
    LEFT JOIN "NEW_YORK_CITIBIKE_1"."GEO_US_BOUNDARIES"."ZIP_CODES" z
        ON ST_WITHIN(ST_POINT(t."start_station_longitude", t."start_station_latitude"), ST_POINT(z."internal_point_lon", z."internal_point_lat"))
    LEFT JOIN "NEW_YORK_CITIBIKE_1"."CYCLISTIC"."ZIP_CODES" c
        ON z."zip_code"::TEXT = c."zip"::TEXT
),
mapped_end_neighborhoods AS (
    -- Map trip end latitude/longitude to ZIP codes for end neighborhood details
    SELECT 
        t.*,
        z."city" AS "end_city", 
        c."borough" AS "end_borough", 
        c."neighborhood" AS "end_neighborhood"
    FROM trip_data t
    LEFT JOIN "NEW_YORK_CITIBIKE_1"."GEO_US_BOUNDARIES"."ZIP_CODES" z
        ON ST_WITHIN(ST_POINT(t."end_station_longitude", t."end_station_latitude"), ST_POINT(z."internal_point_lon", z."internal_point_lat"))
    LEFT JOIN "NEW_YORK_CITIBIKE_1"."CYCLISTIC"."ZIP_CODES" c
        ON z."zip_code"::TEXT = c."zip"::TEXT
),
joined_data AS (
    -- Join trip data with weather data based on the trip start date
    SELECT 
        sn."start_neighborhood", sn."start_borough", en."end_neighborhood", en."end_borough",
        sn."tripduration", sn."start_date", sn."start_city", en."end_city",
        w."avg_temp_f", 
        w."avg_wind_speed_knots", 
        w."precipitation_inches", 
        EXTRACT(MONTH FROM sn."start_date") AS "trip_month"
    FROM mapped_start_neighborhoods sn
    JOIN mapped_end_neighborhoods en
        ON sn."tripduration" = en."tripduration"
       AND sn."start_date" = en."start_date"
    LEFT JOIN weather_data w
        ON DATE(sn."start_date") = DATE_FROM_PARTS(w."year", w."month", w."day")
),
trip_month_counts AS (
    -- Count trips for each neighborhood pair and month to determine the most popular month
    SELECT 
        "start_neighborhood", "start_borough", 
        "end_neighborhood", "end_borough", 
        "trip_month", COUNT(*) AS "month_trip_count"
    FROM joined_data
    GROUP BY "start_neighborhood", "start_borough", "end_neighborhood", "end_borough", "trip_month"
),
most_popular_months AS (
    -- Determine the most popular month for each neighborhood pair
    SELECT 
        "start_neighborhood", "start_borough", 
        "end_neighborhood", "end_borough", 
        "trip_month" AS "most_popular_month"
    FROM (
        SELECT 
            "start_neighborhood", "start_borough", 
            "end_neighborhood", "end_borough", 
            "trip_month", 
            ROW_NUMBER() OVER (PARTITION BY "start_neighborhood", "start_borough", "end_neighborhood", "end_borough" ORDER BY "month_trip_count" DESC) AS "rank"
        FROM trip_month_counts
    ) ranked_months
    WHERE "rank" = 1
),
final_aggregated_data AS (
    -- Aggregate the results to summarize trip stats by starting and ending neighborhoods
    SELECT 
        jd."start_neighborhood", jd."start_borough", 
        jd."end_neighborhood", jd."end_borough",
        COUNT(*) AS "total_trips",
        ROUND(AVG(jd."tripduration") / 60, 1) AS "avg_trip_duration_minutes",
        ROUND(AVG(jd."avg_temp_f"), 1) AS "avg_temp_fahrenheit",
        ROUND(AVG(jd."avg_wind_speed_knots") * 0.514444, 1) AS "avg_wind_speed_meters_per_sec", -- Convert knots to meters/sec
        ROUND(AVG(jd."precipitation_inches") * 2.54, 1) AS "avg_precipitation_cm" -- Convert inches to cm
    FROM joined_data jd
    GROUP BY jd."start_neighborhood", jd."start_borough", jd."end_neighborhood", jd."end_borough"
)
SELECT 
    fad."start_neighborhood", fad."start_borough", 
    fad."end_neighborhood", fad."end_borough", 
    fad."total_trips", fad."avg_trip_duration_minutes", 
    fad."avg_temp_fahrenheit", fad."avg_wind_speed_meters_per_sec", 
    fad."avg_precipitation_cm", mp."most_popular_month"
FROM final_aggregated_data fad
LEFT JOIN most_popular_months mp
    ON fad."start_neighborhood" = mp."start_neighborhood"
    AND fad."start_borough" = mp."start_borough"
    AND fad."end_neighborhood" = mp."end_neighborhood"
    AND fad."end_borough" = mp."end_borough"
ORDER BY fad."total_trips" DESC NULLS LAST;