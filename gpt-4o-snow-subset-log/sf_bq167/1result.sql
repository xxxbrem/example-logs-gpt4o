WITH UpvotePairs AS (
  SELECT 
    "FromUserId", 
    "ToUserId", 
    COUNT(DISTINCT "Id") AS "UpvoteCount"
  FROM META_KAGGLE.META_KAGGLE.FORUMMESSAGEVOTES
  GROUP BY "FromUserId", "ToUserId"
),
RankedPairs AS (
  SELECT 
    fp1."FromUserId",
    fp1."ToUserId",
    fp1."UpvoteCount" AS "GivenUpvotes",
    fp2."UpvoteCount" AS "ReturnedUpvotes",
    RANK() OVER (ORDER BY fp1."UpvoteCount" DESC, fp2."UpvoteCount" DESC NULLS LAST) AS "Rank"
  FROM UpvotePairs fp1
  LEFT JOIN UpvotePairs fp2 
    ON fp1."FromUserId" = fp2."ToUserId" AND fp1."ToUserId" = fp2."FromUserId"
)
SELECT 
  u1."UserName" AS "GiverUserName",
  u2."UserName" AS "RecipientUserName",
  rp."GivenUpvotes",
  rp."ReturnedUpvotes"
FROM RankedPairs rp
LEFT JOIN META_KAGGLE.META_KAGGLE.USERS u1 ON rp."FromUserId" = u1."Id"
LEFT JOIN META_KAGGLE.META_KAGGLE.USERS u2 ON rp."ToUserId" = u2."Id"
WHERE rp."Rank" = 1;