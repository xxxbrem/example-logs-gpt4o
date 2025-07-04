SELECT 
    r."repo_name", 
    r."watch_count"
FROM GITHUB_REPOS.GITHUB_REPOS.SAMPLE_REPOS AS r
JOIN (
    SELECT DISTINCT f."repo_name"
    FROM GITHUB_REPOS.GITHUB_REPOS.SAMPLE_FILES AS f
    JOIN GITHUB_REPOS.GITHUB_REPOS.SAMPLE_CONTENTS AS c
    ON f."id" = c."id"
    WHERE f."path" ILIKE '%.py%' 
      AND c."size" < 15000 
      AND c."content" ILIKE '%def%'
) AS valid_repos
ON r."repo_name" = valid_repos."repo_name"
ORDER BY r."watch_count" DESC NULLS LAST
LIMIT 3;