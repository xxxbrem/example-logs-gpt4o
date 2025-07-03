SELECT 
    u1."UserName" AS "GiverUserName", 
    u2."UserName" AS "RecipientUserName",
    COUNT(DISTINCT fv1."ForumMessageId") AS "VotesGiven",
    COUNT(DISTINCT fv2."ForumMessageId") AS "VotesReturned"
FROM META_KAGGLE.META_KAGGLE.FORUMMESSAGEVOTES fv1
LEFT JOIN META_KAGGLE.META_KAGGLE.FORUMMESSAGEVOTES fv2
  ON fv1."FromUserId" = fv2."ToUserId" 
  AND fv1."ToUserId" = fv2."FromUserId"
LEFT JOIN META_KAGGLE.META_KAGGLE.USERS u1 
  ON fv1."FromUserId" = u1."Id"
LEFT JOIN META_KAGGLE.META_KAGGLE.USERS u2 
  ON fv1."ToUserId" = u2."Id"
GROUP BY u1."UserName", u2."UserName"
ORDER BY "VotesGiven" DESC NULLS LAST, "VotesReturned" DESC NULLS LAST
LIMIT 1;