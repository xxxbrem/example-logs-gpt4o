SELECT s."repo_name", c."id", c."copies"
FROM GITHUB_REPOS.GITHUB_REPOS.SAMPLE_FILES s
JOIN GITHUB_REPOS.GITHUB_REPOS.SAMPLE_CONTENTS c
ON s."id" = c."id"
JOIN GITHUB_REPOS.GITHUB_REPOS.LANGUAGES l
ON s."repo_name" = l."repo_name"
WHERE c."binary" = FALSE 
  AND l."language" ILIKE '%swift%'
ORDER BY c."copies" DESC NULLS LAST
LIMIT 1;