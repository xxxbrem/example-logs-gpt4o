SELECT 
    u1."UserName" AS "GiverUserName", 
    u2."UserName" AS "RecipientUserName",
    COUNT(DISTINCT fv1."Id") AS "DistinctUpvotesGiven",
    COUNT(DISTINCT fv2."Id") AS "DistinctUpvotesReturned"
FROM META_KAGGLE.META_KAGGLE.FORUMMESSAGEVOTES fv1
LEFT JOIN META_KAGGLE.META_KAGGLE.FORUMMESSAGEVOTES fv2 
    ON fv1."FromUserId" = fv2."ToUserId" 
    AND fv1."ToUserId" = fv2."FromUserId"
INNER JOIN META_KAGGLE.META_KAGGLE.USERS u1 
    ON fv1."FromUserId" = u1."Id"
INNER JOIN META_KAGGLE.META_KAGGLE.USERS u2 
    ON fv1."ToUserId" = u2."Id"
GROUP BY u1."UserName", u2."UserName"
ORDER BY "DistinctUpvotesGiven" DESC NULLS LAST, "DistinctUpvotesReturned" DESC NULLS LAST
LIMIT 1;