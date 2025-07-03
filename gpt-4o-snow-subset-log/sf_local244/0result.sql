WITH CATEGORIES AS (
    SELECT 
        'Short' AS "Category", 
        t."TrackId", 
        t."Milliseconds"
    FROM MUSIC.MUSIC.TRACK t
    WHERE t."Milliseconds" < (SELECT MIN("Milliseconds") + (AVG("Milliseconds") - MIN("Milliseconds")) / 2 FROM MUSIC.MUSIC.TRACK)
    UNION ALL
    SELECT 
        'Medium' AS "Category", 
        t."TrackId", 
        t."Milliseconds"
    FROM MUSIC.MUSIC.TRACK t
    WHERE t."Milliseconds" BETWEEN 
          (SELECT MIN("Milliseconds") + (AVG("Milliseconds") - MIN("Milliseconds")) / 2 FROM MUSIC.MUSIC.TRACK) AND 
          (SELECT AVG("Milliseconds") + (MAX("Milliseconds") - AVG("Milliseconds")) / 2 FROM MUSIC.MUSIC.TRACK)
    UNION ALL
    SELECT 
        'Long' AS "Category", 
        t."TrackId", 
        t."Milliseconds"
    FROM MUSIC.MUSIC.TRACK t
    WHERE t."Milliseconds" > 
          (SELECT AVG("Milliseconds") + (MAX("Milliseconds") - AVG("Milliseconds")) / 2 FROM MUSIC.MUSIC.TRACK)
)
SELECT 
    c."Category", 
    MIN(c."Milliseconds") / 60000 AS "MinDurationMinutes",
    MAX(c."Milliseconds") / 60000 AS "MaxDurationMinutes",
    SUM(il."UnitPrice" * il."Quantity") AS "TotalRevenue"
FROM CATEGORIES c
JOIN MUSIC.MUSIC.INVOICELINE il
ON c."TrackId" = il."TrackId"
GROUP BY c."Category";