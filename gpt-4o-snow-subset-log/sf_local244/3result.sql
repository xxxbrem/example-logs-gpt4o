WITH DurationStats AS (
    SELECT 
        MIN("Milliseconds") AS "MinDuration",
        AVG("Milliseconds") AS "AvgDuration",
        MAX("Milliseconds") AS "MaxDuration"
    FROM MUSIC.MUSIC.TRACK
), CategorizedTracks AS (
    SELECT 
        t."TrackId",
        (t."Milliseconds" / 1000 / 60) AS "DurationInMinutes",
        CASE 
            WHEN t."Milliseconds" <= (DurationStats."MinDuration" + (DurationStats."AvgDuration" - DurationStats."MinDuration") / 2) THEN 'Short'
            WHEN t."Milliseconds" <= (DurationStats."AvgDuration" + (DurationStats."MaxDuration" - DurationStats."AvgDuration") / 2) THEN 'Medium'
            ELSE 'Long'
        END AS "DurationCategory"
    FROM MUSIC.MUSIC.TRACK t, DurationStats
), RevenuePerTrack AS (
    SELECT 
        "TrackId",
        SUM("UnitPrice" * "Quantity") AS "TotalRevenue"
    FROM MUSIC.MUSIC.INVOICELINE
    GROUP BY "TrackId"
)
SELECT 
    c."DurationCategory",
    MIN(c."DurationInMinutes") AS "MinDurationInMinutes",
    MAX(c."DurationInMinutes") AS "MaxDurationInMinutes",
    SUM(r."TotalRevenue") AS "TotalRevenueByCategory"
FROM CategorizedTracks c
LEFT JOIN RevenuePerTrack r ON c."TrackId" = r."TrackId"
GROUP BY c."DurationCategory";