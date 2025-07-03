WITH Precomputed AS (
    SELECT 
        MIN("Milliseconds") AS "Min_Milliseconds",
        AVG("Milliseconds") AS "Avg_Milliseconds",
        MAX("Milliseconds") AS "Max_Milliseconds"
    FROM MUSIC.MUSIC.TRACK
)
SELECT 
    CASE 
        WHEN t."Milliseconds" <= (p."Min_Milliseconds" + (p."Avg_Milliseconds" - p."Min_Milliseconds") / 2) THEN 'Short'
        WHEN t."Milliseconds" > (p."Min_Milliseconds" + (p."Avg_Milliseconds" - p."Min_Milliseconds") / 2)
             AND t."Milliseconds" <= (p."Avg_Milliseconds" + (p."Max_Milliseconds" - p."Avg_Milliseconds") / 2) THEN 'Medium'
        ELSE 'Long'
    END AS "Duration_Category",
    MIN(t."Milliseconds") / 60000.0 AS "Min_Duration_Minutes",
    MAX(t."Milliseconds") / 60000.0 AS "Max_Duration_Minutes",
    SUM(il."UnitPrice" * il."Quantity") AS "Total_Revenue"
FROM MUSIC.MUSIC.TRACK t
CROSS JOIN Precomputed p
JOIN MUSIC.MUSIC.INVOICELINE il
ON t."TrackId" = il."TrackId"
GROUP BY 
    CASE 
        WHEN t."Milliseconds" <= (p."Min_Milliseconds" + (p."Avg_Milliseconds" - p."Min_Milliseconds") / 2) THEN 'Short'
        WHEN t."Milliseconds" > (p."Min_Milliseconds" + (p."Avg_Milliseconds" - p."Min_Milliseconds") / 2)
             AND t."Milliseconds" <= (p."Avg_Milliseconds" + (p."Max_Milliseconds" - p."Avg_Milliseconds") / 2) THEN 'Medium'
        ELSE 'Long'
    END;