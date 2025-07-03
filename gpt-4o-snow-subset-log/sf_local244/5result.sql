WITH millisecond_bounds AS (
    SELECT 
        MIN("Milliseconds") AS "Min_Milliseconds", 
        AVG("Milliseconds") AS "Avg_Milliseconds", 
        MAX("Milliseconds") AS "Max_Milliseconds",
        ("Min_Milliseconds" + AVG("Milliseconds")) / 2 AS "Mid_Min_Avg",
        ("Avg_Milliseconds" + MAX("Milliseconds")) / 2 AS "Mid_Avg_Max"
    FROM MUSIC.MUSIC.TRACK
),
categorized_tracks AS (
    SELECT 
        t."TrackId",
        t."Milliseconds",
        CASE 
            WHEN t."Milliseconds" <= mb."Mid_Min_Avg" THEN 'Short'
            WHEN t."Milliseconds" <= mb."Mid_Avg_Max" THEN 'Medium'
            ELSE 'Long'
        END AS "Duration_Category"
    FROM MUSIC.MUSIC.TRACK t
    CROSS JOIN millisecond_bounds mb
),
track_revenue AS (
    SELECT 
        il."TrackId", 
        SUM(il."UnitPrice" * il."Quantity") AS "Total_Revenue"
    FROM MUSIC.MUSIC.INVOICELINE il
    GROUP BY il."TrackId"
)
SELECT 
    ct."Duration_Category",
    COUNT(ct."TrackId") AS "Total_Tracks",
    MIN(ct."Milliseconds") / 60000 AS "Min_Duration_Minutes",
    MAX(ct."Milliseconds") / 60000 AS "Max_Duration_Minutes",
    COALESCE(SUM(tr."Total_Revenue"), 0) AS "Total_Revenue_Per_Category"
FROM categorized_tracks ct
LEFT JOIN track_revenue tr
ON ct."TrackId" = tr."TrackId"
GROUP BY ct."Duration_Category";