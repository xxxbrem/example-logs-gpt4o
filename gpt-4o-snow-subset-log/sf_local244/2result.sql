WITH DurationRanges AS (
    SELECT
        MIN("Milliseconds") AS "Min",
        MAX("Milliseconds") AS "Max",
        AVG("Milliseconds") AS "Avg"
    FROM MUSIC.MUSIC.TRACK
),
TrackRevenue AS (
    SELECT 
        t."TrackId",
        t."Milliseconds",
        SUM(il."Quantity" * il."UnitPrice") AS "TotalRevenue"
    FROM MUSIC.MUSIC.TRACK t
    LEFT JOIN MUSIC.MUSIC.INVOICELINE il
    ON t."TrackId" = il."TrackId"
    GROUP BY t."TrackId", t."Milliseconds"
),
TrackClassification AS (
    SELECT 
        tr."TrackId", 
        tr."Milliseconds",
        tr."TotalRevenue",
        CASE 
            WHEN tr."Milliseconds" BETWEEN (SELECT "Min" FROM DurationRanges) 
                                      AND (SELECT ("Min" + "Avg") / 2 FROM DurationRanges) 
                THEN 'Short'
            WHEN tr."Milliseconds" BETWEEN (SELECT ("Min" + "Avg") / 2 FROM DurationRanges) 
                                      AND (SELECT ("Avg" + "Max") / 2 FROM DurationRanges) 
                THEN 'Medium'
            WHEN tr."Milliseconds" BETWEEN (SELECT ("Avg" + "Max") / 2 FROM DurationRanges) 
                                      AND (SELECT "Max" FROM DurationRanges) 
                THEN 'Long'
        END AS "DurationCategory"
    FROM TrackRevenue tr
)
SELECT 
    "DurationCategory", 
    MIN("Milliseconds") / 60000 AS "MinTimeInMinutes", 
    MAX("Milliseconds") / 60000 AS "MaxTimeInMinutes", 
    SUM("TotalRevenue") AS "TotalRevenue"
FROM TrackClassification
GROUP BY "DurationCategory";