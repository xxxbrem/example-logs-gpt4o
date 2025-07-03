WITH DurationClassification AS (
    SELECT 
        "TrackId",
        "Milliseconds",
        "UnitPrice",
        CASE 
            WHEN "Milliseconds" < ((MIN("Milliseconds") OVER ()) + (AVG("Milliseconds") OVER ())) / 2 THEN 'Short'
            WHEN "Milliseconds" <= ((AVG("Milliseconds") OVER ()) + (MAX("Milliseconds") OVER ())) / 2 THEN 'Medium'
            ELSE 'Long'
        END AS "DurationCategory"
    FROM MUSIC.MUSIC."TRACK"
)
SELECT 
    "DurationCategory", 
    MIN("Milliseconds") / 60000.0 AS "MinDurationMinutes",
    MAX("Milliseconds") / 60000.0 AS "MaxDurationMinutes",
    SUM("UnitPrice") AS "TotalRevenue"
FROM DurationClassification
GROUP BY "DurationCategory";