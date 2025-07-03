SELECT sr."repo_name", sr."watch_count"
FROM GITHUB_REPOS.GITHUB_REPOS.SAMPLE_REPOS sr
WHERE sr."repo_name" IN (
    SELECT DISTINCT sf."repo_name"
    FROM GITHUB_REPOS.GITHUB_REPOS.SAMPLE_FILES sf
    JOIN GITHUB_REPOS.GITHUB_REPOS.SAMPLE_CONTENTS sc
    ON sf."id" = sc."id"
    WHERE sf."path" ILIKE '%.py%' AND sc."content" ILIKE '%def %' AND sc."size" < 15000
)
ORDER BY sr."watch_count" DESC NULLS LAST
LIMIT 3;