WITH Shortest_NXT_Match AS (
    SELECT 
        "winner_id", 
        "loser_id", 
        "title_id", 
        "duration" 
    FROM "WWE"."WWE"."MATCHES" 
    WHERE 
        "title_id" IN (
            SELECT "id" 
            FROM "WWE"."WWE"."BELTS" 
            WHERE "name" ILIKE '%NXT%'
        )
        AND "title_change" = 0 
        AND "duration" IS NOT NULL
    ORDER BY "duration" ASC
    LIMIT 1
),
Wrestler_Names AS (
    SELECT 
        "id", 
        "name" 
    FROM "WWE"."WWE"."WRESTLERS"
)
SELECT 
    winner."name" AS winner_name, 
    loser."name" AS loser_name 
FROM Shortest_NXT_Match AS match
JOIN Wrestler_Names AS winner
    ON match."winner_id" = winner."id"
JOIN Wrestler_Names AS loser
    ON match."loser_id" = loser."id";