WITH MutualUpvotes AS (
    SELECT 
        a."FromUserId" AS "User1", 
        a."ToUserId" AS "User2", 
        COUNT(DISTINCT a."Id") AS "UpvotesGivenByUser1", 
        COUNT(DISTINCT b."Id") AS "UpvotesGivenByUser2"
    FROM META_KAGGLE.META_KAGGLE.FORUMMESSAGEVOTES a
    JOIN META_KAGGLE.META_KAGGLE.FORUMMESSAGEVOTES b 
        ON a."FromUserId" = b."ToUserId" 
        AND a."ToUserId" = b."FromUserId"
    GROUP BY a."FromUserId", a."ToUserId"
    ORDER BY "UpvotesGivenByUser1" DESC NULLS LAST, "UpvotesGivenByUser2" DESC NULLS LAST
    LIMIT 1
)
SELECT 
    u1."UserName" AS "User1UserName", 
    u2."UserName" AS "User2UserName", 
    u1."DisplayName" AS "User1DisplayName", 
    u2."DisplayName" AS "User2DisplayName", 
    mu."UpvotesGivenByUser1", 
    mu."UpvotesGivenByUser2"
FROM MutualUpvotes mu
JOIN META_KAGGLE.META_KAGGLE.USERS u1 ON u1."Id" = mu."User1"
JOIN META_KAGGLE.META_KAGGLE.USERS u2 ON u2."Id" = mu."User2";