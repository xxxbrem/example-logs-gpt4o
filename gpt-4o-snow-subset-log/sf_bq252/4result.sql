SELECT c."sample_repo_name", c."copies", c."id", s."path"
FROM GITHUB_REPOS.GITHUB_REPOS.SAMPLE_CONTENTS c
JOIN GITHUB_REPOS.GITHUB_REPOS.SAMPLE_FILES s ON c."id" = s."id"
WHERE c."binary" = FALSE AND s."path" ILIKE '%.swift'
ORDER BY c."copies" DESC NULLS LAST
LIMIT 1;