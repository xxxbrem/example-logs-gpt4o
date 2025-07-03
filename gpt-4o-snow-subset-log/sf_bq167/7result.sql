WITH RankedVotes AS (
  SELECT 
    u1."UserName" AS "FromUserName",
    u2."UserName" AS "ToUserName",
    COUNT(DISTINCT f1."ForumMessageId") AS "UpvotesGiven",
    COALESCE(
      (SELECT COUNT(DISTINCT f2."ForumMessageId")
       FROM META_KAGGLE.META_KAGGLE.FORUMMESSAGEVOTES f2
       WHERE f2."FromUserId" = f1."ToUserId" AND f2."ToUserId" = f1."FromUserId"), 0
    ) AS "UpvotesReturned"
  FROM META_KAGGLE.META_KAGGLE.FORUMMESSAGEVOTES f1
  JOIN META_KAGGLE.META_KAGGLE.USERS u1 ON f1."FromUserId" = u1."Id"
  JOIN META_KAGGLE.META_KAGGLE.USERS u2 ON f1."ToUserId" = u2."Id"
  GROUP BY u1."UserName", u2."UserName", f1."FromUserId", f1."ToUserId"
)
SELECT *
FROM RankedVotes
ORDER BY "UpvotesGiven" DESC NULLS LAST, "UpvotesReturned" DESC NULLS LAST
LIMIT 1;