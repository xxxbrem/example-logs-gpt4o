WITH Stats AS (
    SELECT 
        MIN("Milliseconds") AS "Min_Milliseconds",
        MAX("Milliseconds") AS "Max_Milliseconds",
        AVG("Milliseconds") AS "Avg_Milliseconds"
    FROM MUSIC.MUSIC.TRACK
),
ClassifiedTracks AS (
    SELECT 
        t."TrackId",
        (t."Milliseconds" / 1000 / 60) AS "Duration_Minutes",
        CASE 
            WHEN t."Milliseconds" <= (Stats."Min_Milliseconds" + (Stats."Avg_Milliseconds" - Stats."Min_Milliseconds") / 2) THEN 'Short'
            WHEN t."Milliseconds" <= (Stats."Avg_Milliseconds" + (Stats."Max_Milliseconds" - Stats."Avg_Milliseconds") / 2) THEN 'Medium'
            ELSE 'Long'
        END AS "Category"
    FROM MUSIC.MUSIC.TRACK t, Stats
),
TrackRevenue AS (
    SELECT 
        i."TrackId",
        SUM(i."UnitPrice" * i."Quantity") AS "Total_Revenue"
    FROM MUSIC.MUSIC.INVOICELINE i
    GROUP BY i."TrackId"
)
SELECT 
    c."Category",
    MIN(c."Duration_Minutes") AS "Min_Duration_Minutes",
    MAX(c."Duration_Minutes") AS "Max_Duration_Minutes",
    SUM(COALESCE(tr."Total_Revenue", 0)) AS "Total_Revenue"
FROM ClassifiedTracks c
LEFT JOIN TrackRevenue tr
ON c."TrackId" = tr."TrackId"
GROUP BY c."Category";