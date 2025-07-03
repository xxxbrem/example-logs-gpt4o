WITH VoteCount AS (
    SELECT 
        "FromUserId", 
        "ToUserId", 
        COUNT(DISTINCT "Id") AS "Upvotes_Given"
    FROM 
        META_KAGGLE.META_KAGGLE.FORUMMESSAGEVOTES
    GROUP BY 
        "FromUserId", "ToUserId"
),
ReverseVoteCount AS (
    SELECT 
        "FromUserId" AS "ToUserId", 
        "ToUserId" AS "FromUserId", 
        COUNT(DISTINCT "Id") AS "Upvotes_Received"
    FROM 
        META_KAGGLE.META_KAGGLE.FORUMMESSAGEVOTES
    GROUP BY 
        "FromUserId", "ToUserId"
),
TopInteractions AS (
    SELECT 
        vc."FromUserId", 
        vc."ToUserId", 
        vc."Upvotes_Given", 
        COALESCE(rvc."Upvotes_Received", 0) AS "Upvotes_Received"
    FROM 
        VoteCount vc
    LEFT JOIN 
        ReverseVoteCount rvc
    ON 
        vc."FromUserId" = rvc."FromUserId" AND vc."ToUserId" = rvc."ToUserId"
    ORDER BY 
        vc."Upvotes_Given" DESC NULLS LAST, 
        rvc."Upvotes_Received" DESC NULLS LAST
    LIMIT 1
)
SELECT 
    u1."UserName" AS "From_UserName", 
    u1."DisplayName" AS "From_DisplayName", 
    u2."UserName" AS "To_UserName", 
    u2."DisplayName" AS "To_DisplayName", 
    ti."Upvotes_Given", 
    ti."Upvotes_Received"
FROM 
    TopInteractions ti
JOIN 
    META_KAGGLE.META_KAGGLE.USERS u1
ON 
    ti."FromUserId" = u1."Id"
JOIN 
    META_KAGGLE.META_KAGGLE.USERS u2
ON 
    ti."ToUserId" = u2."Id";