WITH NormalizedVotes AS (
    SELECT 
        LEAST(v."FromUserId", v."ToUserId") AS "NormalizedFromUserId",
        GREATEST(v."FromUserId", v."ToUserId") AS "NormalizedToUserId",
        COUNT(DISTINCT v."ForumMessageId") AS "VotesGiven"
    FROM META_KAGGLE.META_KAGGLE.FORUMMESSAGEVOTES v
    GROUP BY LEAST(v."FromUserId", v."ToUserId"), GREATEST(v."FromUserId", v."ToUserId")
),
VotesWithUsernames AS (
    SELECT
        nv."NormalizedFromUserId",
        nv."NormalizedToUserId",
        nv."VotesGiven",
        giver."UserName" AS "GiverUserName",
        receiver."UserName" AS "ReceiverUserName"
    FROM NormalizedVotes nv
    LEFT JOIN META_KAGGLE.META_KAGGLE.USERS giver ON nv."NormalizedFromUserId" = giver."Id"
    LEFT JOIN META_KAGGLE.META_KAGGLE.USERS receiver ON nv."NormalizedToUserId" = receiver."Id"
)
SELECT 
    vw1."GiverUserName" AS "User1",
    vw1."ReceiverUserName" AS "User2",
    vw1."VotesGiven" AS "VotesFromUser1ToUser2",
    COALESCE(vw2."VotesGiven", 0) AS "VotesFromUser2ToUser1"
FROM VotesWithUsernames vw1
LEFT JOIN VotesWithUsernames vw2
    ON vw1."NormalizedFromUserId" = vw2."NormalizedToUserId"
   AND vw1."NormalizedToUserId" = vw2."NormalizedFromUserId"
ORDER BY vw1."VotesGiven" DESC NULLS LAST, COALESCE(vw2."VotesGiven", 0) DESC NULLS LAST
LIMIT 1;