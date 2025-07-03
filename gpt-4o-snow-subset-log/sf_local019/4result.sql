SELECT 
    w1."name" AS "winner_name", 
    w2."name" AS "loser_name" 
FROM WWE.WWE.WRESTLERS w1 
JOIN WWE.WWE.WRESTLERS w2 
ON w1."id" = (SELECT "winner_id" 
              FROM WWE.WWE.MATCHES 
              WHERE "title_id" IN (SELECT "id" FROM WWE.WWE.BELTS WHERE "name" ILIKE '%NXT%')  -- Handle multiple "NXT" title IDs
                AND "title_change" = 0 
              ORDER BY TRY_TO_NUMBER(SPLIT_PART("duration", ':', 1)) ASC NULLS LAST, 
                       TRY_TO_NUMBER(SPLIT_PART("duration", ':', 2)) ASC NULLS LAST  -- Correctly sort "duration" by minutes and seconds
              LIMIT 1) 
AND w2."id" = (SELECT "loser_id" 
              FROM WWE.WWE.MATCHES 
              WHERE "title_id" IN (SELECT "id" FROM WWE.WWE.BELTS WHERE "name" ILIKE '%NXT%')  -- Handle multiple "NXT" title IDs
                AND "title_change" = 0 
              ORDER BY TRY_TO_NUMBER(SPLIT_PART("duration", ':', 1)) ASC NULLS LAST, 
                       TRY_TO_NUMBER(SPLIT_PART("duration", ':', 2)) ASC NULLS LAST  -- Correctly sort "duration" by minutes and seconds
              LIMIT 1);