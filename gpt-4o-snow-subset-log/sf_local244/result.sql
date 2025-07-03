WITH DurationBoundaries AS (
    SELECT 
        MIN("Milliseconds") AS "MinMilliseconds",
        AVG("Milliseconds") AS "AvgMilliseconds",
        MAX("Milliseconds") AS "MaxMilliseconds",
        -- Define thresholds for categorization:
        (MIN("Milliseconds") + (AVG("Milliseconds") - MIN("Milliseconds")) / 2) AS "ShortThreshold",
        (AVG("Milliseconds") + (MAX("Milliseconds") - AVG("Milliseconds")) / 2) AS "MediumThreshold"
    FROM MUSIC.MUSIC.TRACK
),
ClassifiedTracks AS (
    SELECT 
        t."TrackId",
        t."Milliseconds",
        i."Quantity" * i."UnitPrice" AS "Revenue",
        CASE 
            WHEN t."Milliseconds" < d."ShortThreshold" THEN 'Short'
            WHEN t."Milliseconds" BETWEEN d."ShortThreshold" AND d."MediumThreshold" THEN 'Medium'
            ELSE 'Long'
        END AS "DurationCategory"
    FROM MUSIC.MUSIC.TRACK t
    JOIN MUSIC.MUSIC.INVOICELINE i
        ON t."TrackId" = i."TrackId"
    CROSS JOIN DurationBoundaries d
)
SELECT 
    "DurationCategory",
    MIN("Milliseconds") / 60000 AS "MinDurationMinutes",
    MAX("Milliseconds") / 60000 AS "MaxDurationMinutes",
    SUM("Revenue") AS "TotalRevenue"
FROM ClassifiedTracks
GROUP BY "DurationCategory";