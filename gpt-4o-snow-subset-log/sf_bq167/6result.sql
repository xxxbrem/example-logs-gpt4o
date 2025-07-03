SELECT 
    u1."UserName" AS "Giver_Username", 
    u2."UserName" AS "Recipient_Username", 
    v."Given_Votes", 
    v."Returned_Votes"
FROM (
    SELECT 
        v1."FromUserId", 
        v1."ToUserId", 
        COUNT(DISTINCT v1."Id") AS "Given_Votes", 
        COUNT(DISTINCT v2."Id") AS "Returned_Votes"
    FROM META_KAGGLE.META_KAGGLE.FORUMMESSAGEVOTES v1
    LEFT JOIN META_KAGGLE.META_KAGGLE.FORUMMESSAGEVOTES v2 
      ON v1."FromUserId" = v2."ToUserId" AND v1."ToUserId" = v2."FromUserId"
    GROUP BY v1."FromUserId", v1."ToUserId"
    ORDER BY "Given_Votes" DESC NULLS LAST, "Returned_Votes" DESC NULLS LAST
    LIMIT 1
) v
INNER JOIN META_KAGGLE.META_KAGGLE.USERS u1 
  ON v."FromUserId" = u1."Id"
INNER JOIN META_KAGGLE.META_KAGGLE.USERS u2 
  ON v."ToUserId" = u2."Id";