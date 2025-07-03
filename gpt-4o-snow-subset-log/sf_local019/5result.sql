WITH shortest_nxt_match AS (
    -- Step 1: Filter for matches with the NXT title by joining MATCHES and BELTS tables based on title_id
    SELECT 
        M."id" AS match_id, 
        M."winner_id", 
        M."loser_id", 
        M."duration"
    FROM 
        WWE.WWE.MATCHES M
    JOIN 
        WWE.WWE.BELTS B 
    ON 
        M."title_id" = B."id"
    WHERE 
        LOWER(B."name") LIKE '%nxt%' -- Check for titles containing "NXT" (case-insensitive match)
        AND M."title_change" = 0     -- Exclude title-change matches
        AND M."duration" IS NOT NULL -- Ensure the duration is not null
    ORDER BY 
        LENGTH(M."duration") ASC,    -- Order by shortest duration
        M."duration" ASC
    LIMIT 
        1
)
-- Step 2: Retrieve the names of the wrestlers involved in the shortest NXT match
SELECT 
    W1."name" AS winner_name, 
    W2."name" AS loser_name
FROM 
    shortest_nxt_match SNM
JOIN 
    WWE.WWE.WRESTLERS W1 
ON 
    CAST(SNM."winner_id" AS NUMBER) = W1."id" -- Ensure IDs match and typecast if needed
JOIN 
    WWE.WWE.WRESTLERS W2 
ON 
    CAST(SNM."loser_id" AS NUMBER) = W2."id";